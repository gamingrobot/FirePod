//
//  PlayViewController.m
//  FirePod
//
//  Created by GamingRobot on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"
#import "DataManagment.h"
#import "TouchXML/TouchXML.h"

#define kDefaultReflectionFraction 0.25
#define kDefaultReflectionOpacity 0.75
#define DATABASE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/firepod.sqlite"]
@implementation PlayViewController
@synthesize row_selected, albumArt, infoView;

-(IBAction)backButton:(id)sender {
	
	[self.navigationController popToRootViewControllerAnimated:YES];	
	
}

- (IBAction) play: (id) sender
{
	DataManagment *myManager = [DataManagment sharedDataManager];
	NSString *serverip = myManager.server_ip;
	NSString *serverport = myManager.server_port;
		if (!streamer)
		{		
			
			[play_button setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
			NSLog([NSString stringWithFormat:@"%u", row_selected]);
			NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%@/databases/1/items/%u.mp3", serverip, serverport, row_selected]];
			//NSURL *url = [NSURL URLWithString: @"http://127.0.0.1:3689/databases/1/items/1.mp3"];
			streamer = [[AudioStreamer alloc] initWithURL:url];
			[streamer
			 addObserver:self
			 forKeyPath:@"isPlaying"
			 options:0
			 context:nil];
			[streamer start];
						
		}
		else
		{
			[play_button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
			[streamer stop];
		}

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			[play_button setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];

		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			[play_button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];

		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
	
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (void)LoadAlbumArtwork{
	NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];

	NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				   NULL,
																				   (CFStringRef)[song_info objectAtIndex:1],
																				   NULL,
																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			   kCFStringEncodingUTF8 );
	
	 //use external album art loader	
	 //load album art from server
	NSString* imgUrl = [self stringWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.syberplanet.net/albumart/?q=%@&s=large&m=url", encodedString]]];
	NSString* imageUrl = [imgUrl stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
	UIImage* image = [[UIImage alloc] initWithData:imageData];
	[albumArt setImage:image];
	[imageData release];
	[image release];
	
	//use amazons album art
	//example url http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SearchIndex=Music&SubscriptionId=AKIAI6QTAC3GW6XZ6KVA&ResponseGroup=Images&Keywords=hot%20fuss&Artist=killers
	/*xml fetching */
    /*// Initialize the blogEntries MutableArray that we declared in the header
    NSMutableArray *xmldata = [[NSMutableArray alloc] init];	
	
    // Convert the supplied URL string into a usable URL object
    //NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%@/databases/1/items?output=xml", serverip.text, serverport.text ]];
	NSURL *url = [NSURL URLWithString: @"http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SearchIndex=Music&SubscriptionId=AKIAI6QTAC3GW6XZ6KVA&ResponseGroup=Images&Keywords=hot%20fuss&Artist=killers"];
	
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"ItemSearchResponse/Items/Item/LargeImage" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in blogEntries
        NSMutableDictionary *blogItem = [[NSMutableDictionary alloc] init];
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
			
            // Add each field to the blogItem Dictionary with the node name as key and node value as the value
            [blogItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
			
		}
        // Add the blogItem to the global blogEntries Array so that the view can access it.
        [xmldata addObject:[blogItem copy]];
		
		
	}
		NSLog(@"%@", [[xmldata objectAtIndex:0] objectForKey: @"URL"]);
	*/
	// make reflection 
	reflectionView.image = [self reflectionImage:self.albumArt withHeight:self.albumArt.bounds.size.height * kDefaultReflectionFraction];
	reflectionView.alpha = kDefaultReflectionOpacity;		
	[ pool release ];	
}

- (void)viewWillAppear:(BOOL)animated {
	[db retain];
	DataManagment *myManager = [DataManagment sharedDataManager];
	NSString *serverip = myManager.server_ip;
	NSString *serverport = myManager.server_port;
	if (streamer)
	{		
		[play_button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
		[streamer stop];
		[play_button setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
		NSLog([NSString stringWithFormat:@"%u", row_selected]);
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%@/databases/1/items/%u.mp3", serverip, serverport, row_selected]];
		//NSURL *url = [NSURL URLWithString: @"http://127.0.0.1:3689/databases/1/items/1.mp3"];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer
		 addObserver:self
		 forKeyPath:@"isPlaying"
		 options:0
		 context:nil];
		[streamer start];
		
	}
	else
	{
		[play_button setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
		NSLog([NSString stringWithFormat:@"%u", row_selected]);
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%@/databases/1/items/%u.mp3", serverip, serverport, row_selected]];
		//NSURL *url = [NSURL URLWithString: @"http://127.0.0.1:3689/databases/1/items/1.mp3"];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer
		 addObserver:self
		 forKeyPath:@"isPlaying"
		 options:0
		 context:nil];
		[streamer start];
	}
		[[self navigationController] setNavigationBarHidden:YES animated:NO];
	
	FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM songdata WHERE song_itemid =  '%u'", row_selected]];
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM songdata WHERE song_itemid =  '1'"];
	[song_info removeAllObjects];
	while ([rs next]) {
		NSString *artist = [[rs stringForColumn:@"song_artist"] copy];
		NSString *song = [[rs stringForColumn:@"song_itemname"] copy];
		NSString *album = [[rs stringForColumn:@"song_album"] copy];
		NSString *itemid = [[rs stringForColumn:@"song_itemid"] copy];
		[song_info addObject:artist];
		[song_info addObject:song];
		[song_info addObject:album];
		[song_info addObject:itemid];
		NSLog([song_info objectAtIndex:1]);
		[artist release];
		[song release];
		[album release];
		[itemid release];
	}	
	[NSThread detachNewThreadSelector: @selector(LoadAlbumArtwork) toTarget: self withObject: nil ];
	//[self LoadAlbumArtwork];
	[db release];
}
	
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	song_info = [[NSMutableArray alloc] init];
		db = [FMDatabase databaseWithPath:DATABASE_PATH];
		[db setLogsErrors:TRUE];
		[db setTraceExecution:TRUE];
		[db open];	
		[db retain];
	
}

#pragma mark Reflection Methods


CGImageRef CreateGradientImage(int gradientWidth, int gradiendHeight) {
	CGImageRef theCGImage = NULL;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, gradientWidth, gradiendHeight, 8, 0, colorSpace, kCGImageAlphaNone);
	
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, gradiendHeight);
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
    return theCGImage;
}


- (UIImage *)reflectionImage:(UIImageView *)fromImage withHeight:(NSUInteger)height {
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate (nil, fromImage.bounds.size.width, height, 8, 0, colorSpace, (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
	CGFloat translateVertical= fromImage.bounds.size.height - height;
	CGContextTranslateCTM(bitmapContext, 0, -translateVertical);
	
	CALayer *layer = [fromImage layer];
	[layer renderInContext:bitmapContext];
	
	CGImageRef bitmapImage = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease(bitmapContext);
	
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	CGImageRef reflectionImage = CGImageCreateWithMask(bitmapImage, gradientMaskImage);
	CGImageRelease(bitmapImage);
	CGImageRelease(gradientMaskImage);
	
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	CGImageRelease(reflectionImage);
	
	return theImage;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[song_info release];
	[db close];
    [super dealloc];
}


@end
