//
//  CustomPlayer.h
//  KSKQ Player
//
//  Created by John Fricker on 10/2/08.
//  Copyright 2008 John Fricker Software Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>
#include <pthread.h>

// number of audio queue buffers we allocate
// number of bytes in each audio queue buffer
// number of packet descriptions in our array

#define kNumAQBufs 6
#define kAQBufSize 128000
#define kAQMaxPacketDescs 512

@interface CustomPlayer : NSObject {
	
	
	NSURLRequest *playUrl;
	NSURLConnection *inputStream;
	
	AudioFileStreamID afsID; // ID of the stream parser
	AudioQueueRef audioQueue;
	AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];		// audio queue buffers
	AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];	// packet descriptions for enqueuing audio
	
	unsigned int fillBufferIndex;	// the index of the audioQueueBuffer that is being filled
	size_t bytesFilled;				// how many bytes have been filled
	size_t packetsFilled;			// how many packets have been filled
	
	bool inuse[kNumAQBufs];			// flags to indicate that a buffer is still in use
	bool started;					// flag to indicate that the queue has been started
	bool failed;					// flag to indicate an error occurred
	
	float initialGain;
	
	pthread_mutex_t mutex;			// a mutex to protect the inuse flags
	pthread_cond_t cond;			// a condition varable for handling the inuse flags	
}

- (void) initCustomPlayer;
- (void) setUrl:(NSString *)myUrl;
- (void) play:(float)gain;
- (void) pause;
- (void) stop;
- (void) setGain:(float)gain;
- (void) alertFail;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *) connection;
- (void)propertyListener:(AudioFileStreamID)AudioFileStream propID:(AudioFileStreamPropertyID)PropertyID flags:(UInt32 *)Flags;
- (void)outputCallbackWithBufferReference:(AudioQueueRef)inAQ buffref:(AudioQueueBufferRef)inBuffer;
- (void)packetsProc:(UInt32)inNumberBytes numpackets:(UInt32)inNumberPackets indata:(const void *)inInputData aspd:(AudioStreamPacketDescription *)inPacketDescriptions;
- (void)audioEnqueue;
- (int)findQueueBuffer:(AudioQueueBufferRef)inBuffer;

@end
