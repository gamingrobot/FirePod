//
//  CustomPlayer.m
//  KSKQ Player
//
//  Created by John Fricker on 10/2/08.
//  Copyright 2008 John Fricker Software Development. All rights reserved.
//

#import "CustomPlayer.h"

//These callbacks are C interface functions for the Audio Toolbox library
//They redirect back into the appropriate class methods

void MyPropertyListenerProc(void *inClientData, AudioFileStreamID inAudioFileStream, AudioFileStreamPropertyID inPropertyID, UInt32 * ioFlags)
{
	CustomPlayer *cPlayer = (CustomPlayer *)inClientData;
	[cPlayer propertyListener:inAudioFileStream propID:inPropertyID flags:ioFlags];
}

void MyPacketsProc(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void * inInputData, AudioStreamPacketDescription	*inPacketDescriptions)
{
	CustomPlayer *cPlayer = (CustomPlayer *)inClientData;
	[cPlayer packetsProc:inNumberBytes numpackets:inNumberPackets indata:inInputData aspd:inPacketDescriptions];
}

void MyAudioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
	CustomPlayer *cPlayer = (CustomPlayer*)inClientData;
	[cPlayer outputCallbackWithBufferReference:inAQ buffref:inBuffer];
}
			
@implementation CustomPlayer

- (void) initCustomPlayer
{
//	NSLog(@"Init");
	bytesFilled = 0;
	packetsFilled = 0;
	audioQueue = 0;
	started = false;
	initialGain = 0.5;
	
	for (int i=0; i<kNumAQBufs; i++)
		inuse[i]=false;
}

- (void) setUrl:(NSString *)myUrl 
{
//	NSLog(@"setUrl %@", myUrl);
	NSURL *uServer = [[NSURL alloc] initWithString:myUrl];
	playUrl = [NSURLRequest requestWithURL:uServer
							   cachePolicy:NSURLRequestUseProtocolCachePolicy
						   timeoutInterval:10.0];
	[uServer release];

}

- (void) play:(float)gain 
{
	initialGain = gain;
	// create an audio file stream parser
	OSStatus err = AudioFileStreamOpen(self, MyPropertyListenerProc, MyPacketsProc, 
									   kAudioFileMP3Type, &afsID);
	if (err) { NSLog(@"AudioFileStreamOpen"); return; }
	
	inputStream = [[NSURLConnection alloc] initWithRequest:playUrl delegate:self];
	if (inputStream == nil) {
		NSLog(@"Failed to create connection");
		[self alertFail];
		return;
	}
}

- (void) alertFail {
	[self stop];
	UIAlertView *netAlert = [[UIAlertView alloc] initWithTitle:@"Stream problem" 
													   message:@"The player did not connect to the audio stream. Please check your network and try again." 
													  delegate:self 
											 cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
	[netAlert show];
	[netAlert release];
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"PlayerDidFinishPlayingNotification" object:self];
}

- (void) pause {
//	NSLog(@"pause!");
	if (started)
		AudioQueuePause(audioQueue);
}

- (void) stop 
{
	OSStatus err = noErr;
	
	if (started) {
		AudioQueueFlush(audioQueue);
		err = AudioQueueStop(audioQueue, true);
		if (err) NSLog(@"AudioQueueStop failed");
	
		err = AudioFileStreamClose(afsID);
		if (err) NSLog(@"AudioFileStreamClose failed");

		err = AudioQueueDispose(audioQueue, false);
		if (err) NSLog(@"AudioQueueDispose failed");
	}
	
	started = false;

	if (inputStream) {
		[inputStream cancel];
		[inputStream release];
		inputStream = nil;
	}	

	for (int bufIndex=0; bufIndex<kNumAQBufs; bufIndex++) {
		inuse[bufIndex] = false;
	}
}

- (void) setGain:(float)gain {
	if (started)
		AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, gain);
	else 
		initialGain = gain;
}


/* NSURLConnection Delegate methods */

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)err
{
	NSLog(@"Error connecting! %@", [err localizedFailureReason]);
	[self alertFail];
	//[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
//	NSLog(@"didReceiveData length %d", [data length]);
	OSStatus err = AudioFileStreamParseBytes(afsID, [data length], [data bytes], 0);
	if (err) {
		NSLog(@"AudioFileStreamParseBytes failed!");
		[self alertFail];
		//[connection release];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *) connection 
{
	NSLog(@"connection did finish loading");
	[self alertFail];
	//[connection release];
	
}

/* Internal callback handlers */
- (void)propertyListener:(AudioFileStreamID)inAudioFileStream propID:(AudioFileStreamPropertyID)inPropertyID flags:(UInt32 *)Flags
{
//	NSLog(@"MyPropertyListenerProc");
//	NSLog(@"found property '%c%c%c%c'\n", (inPropertyID>>24)&255, (inPropertyID>>16)&255, (inPropertyID>>8)&255, inPropertyID&255);
	OSStatus err = noErr;
	switch (inPropertyID)
	{
		case kAudioFileStreamProperty_ReadyToProducePackets:
		{
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			
			err = AudioFileStreamGetProperty(inAudioFileStream,  kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if (err) NSLog(@"get kAudioFileStreamProperty_DataFormat failed");
			
			err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, self, NULL, NULL, 0, &audioQueue);
			if (err) NSLog(@"AudioQueueNewOutput failed");

			// allocate audio queue buffers
			for (unsigned int i = 0; i < kNumAQBufs; ++i) {
				err = AudioQueueAllocateBuffer(audioQueue, kAQBufSize, &audioQueueBuffer[i]);
				if (err) { 
					//NSLog(@"AudioQueueAllocateBuffer"); 
					failed = true;
					break; 
				}
			}
			
			// get the cookie size
			UInt32 cookieSize;
			Boolean writable;
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
			if (err) { 
				//NSLog(@"info kAudioFileStreamProperty_MagicCookieData"); 
				break; 
			}
			//printf("cookieSize %d\n", cookieSize);
			
			// get the cookie data
			void* cookieData = calloc(1, cookieSize);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
			if (err) { 
				//NSLog(@"get kAudioFileStreamProperty_MagicCookieData"); 
				free(cookieData); 
				break; 
			}
			
			// set the cookie on the queue.
			err = AudioQueueSetProperty(audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
			free(cookieData);
			if (err) { 
				//NSLog(@"set kAudioQueueProperty_MagicCookie"); 
				break; 
			}
			
			
			break;
		} //case
	} //switch
	
}

- (void)packetsProc:(UInt32)inNumberBytes numpackets:(UInt32)inNumberPackets indata:(const void *)inInputData aspd:(AudioStreamPacketDescription *)inPacketDescriptions
{
//	NSLog(@"packetsProc");
//	NSLog(@"got data.  bytes: %d  packets: %d\n", inNumberBytes, inNumberPackets);
	
	// the following code assumes we're streaming VBR data. for CBR data, you'd need another code branch here.
	
	for (int i = 0; i < inNumberPackets; ++i) {
		SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
		SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
		
		// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
		size_t bufSpaceRemaining = kAQBufSize - bytesFilled;
		if (bufSpaceRemaining < packetSize) {
			[self audioEnqueue];
		}
		
		// copy data to the audio queue buffer
		AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
		memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)inInputData + packetOffset, packetSize);
		// fill out packet description
		packetDescs[packetsFilled] = inPacketDescriptions[i];
		packetDescs[packetsFilled].mStartOffset = bytesFilled;
		// keep track of bytes filled and packets filled
		bytesFilled += packetSize;
		packetsFilled += 1;
		
		// if that was the last free packet description, then enqueue the buffer.
		size_t packetsDescsRemaining = kAQMaxPacketDescs - packetsFilled;
		if (packetsDescsRemaining == 0) {
			[self audioEnqueue];
		}
	}	
	
}

- (void)audioEnqueue
{
	OSStatus err = noErr;
	
	inuse[fillBufferIndex] = true;		// set in use flag
	
	// enqueue buffer
	AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
	fillBuf->mAudioDataByteSize = bytesFilled;		
	err = AudioQueueEnqueueBuffer(audioQueue, fillBuf, packetsFilled, packetDescs);
	if (err) { 
		//NSLog(@"AudioQueueEnqueueBuffer"); 
		failed = true; 
		return ; 
	}		
	
	if (!started) {		// start the queue if it has not been started already
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"PlayerDidStartPlayingNotification" object:self];
		err = AudioQueueStart(audioQueue, NULL);
		if (err) { 
		//	NSLog(@"AudioQueueStart"); 
			failed = true; 
			return ; 
		}		
		started = true;
		[self setGain:initialGain];
	}
	
	// go to next buffer
	if (++fillBufferIndex >= kNumAQBufs) fillBufferIndex = 0;
	bytesFilled = 0;		// reset bytes filled
	packetsFilled = 0;		// reset packets filled
	
	// wait until next buffer is not in use
//	NSLog(@"->lock\n");
	pthread_mutex_lock(&mutex); 
	while (inuse[fillBufferIndex]) {
		//NSLog(@"... WAITING ...\n");
		sleep(1);
		pthread_cond_wait(&cond, &mutex);
	}
	pthread_mutex_unlock(&mutex);
//	NSLog(@"<-unlock\n");
	
	return ;
}

- (int)findQueueBuffer:(AudioQueueBufferRef)inBuffer
{
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (inBuffer == audioQueueBuffer[i]) 
			return i;
	}
	//NSLog(@"queue buffer not found!");
	return -1;
}

- (void)outputCallbackWithBufferReference:(AudioQueueRef)inAQ buffref:(AudioQueueBufferRef)inBuffer
{
	if (!started) return;
//	NSLog(@"outputCallbackWithBufferReference");
	unsigned int bufIndex = [self findQueueBuffer:inBuffer];
//	NSLog(@"Freeing buffer %d", bufIndex);
	if (bufIndex >= 0) {
		// signal waiting thread that the buffer is free.
		pthread_mutex_lock(&mutex);
		inuse[bufIndex] = false;
		pthread_cond_signal(&cond);
		pthread_mutex_unlock(&mutex);	
	}
}

- (void)dealloc
{
	[super dealloc];
}
@end
