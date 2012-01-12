//
//  PlayViewController.h
//  FirePod
//
//  Created by GamingRobot on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AudioStreamer.h"
#import "TrackInfoView.h"
#import "FMDB/FMDatabase.h"
#import <MediaPlayer/MediaPlayer.h>
@interface PlayViewController : UIViewController {
	NSUInteger row_selected;
	AudioStreamer *streamer;
	IBOutlet UIButton *play_button;
	IBOutlet UIImageView		*albumArt;	
	IBOutlet UIImageView		*reflectionView;
	IBOutlet TrackInfoView		*infoView;
	IBOutlet MPVolumeView		*volumeView;
	FMDatabase* db;
	NSMutableArray *song_info;
}
@property (nonatomic) NSUInteger row_selected;

@property (nonatomic, retain) IBOutlet UIImageView *albumArt;
@property (nonatomic, retain) IBOutlet TrackInfoView *infoView;

#pragma mark Reflection Methods
CGImageRef CreateGradientImage(int gradientWidth, int gradiendHeight);
- (UIImage *)reflectionImage:(UIImageView *)fromImage withHeight:(NSUInteger)height;
- (NSString *)stringWithUrl:(NSURL *)url;
- (void)LoadAlbumArtwork;
@end
