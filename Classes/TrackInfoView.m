//
//  TrackInfoView.m
//  TEST_MEDIACONTROL_APP
//
//  Created by Skylar Cantu on 2/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrackInfoView.h"


@implementation TrackInfoView

@synthesize album, artist, song;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self layoutSubviews];
    }
    return self;
}


- (void)layoutSubviews {
	//self.bounds = CGRectMake(self.bounds.origin.x, self.superview.bounds.origin.y, self.bounds.size.width, self.superview.bounds.size.height);
	/*- Alternatively, set the bounds in Interface Builder.  It. by default, reduces the height 12 px and offsets the origin.y 6 px -*/
	self.bounds = CGRectMake(0, 0, 100, 40);

	CGRect frame = self.frame;
	CGRect artistRect	= CGRectMake(0, 0, frame.size.width, frame.size.height / 3);
	CGRect songRect		= CGRectMake(0, frame.size.height / 3, frame.size.width, frame.size.height / 3);
	CGRect albumRect	= CGRectMake(0, (frame.size.height / 3) * 2, frame.size.width, frame.size.height / 3);
	
	album = [[UILabel alloc] initWithFrame:albumRect];
	album.backgroundColor = [UIColor clearColor];
	album.font = [UIFont boldSystemFontOfSize:12];
	album.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
	album.shadowOffset = CGSizeMake(0, -1);
	album.text = @"Album";
	album.textAlignment = UITextAlignmentCenter;
	album.textColor = [UIColor lightGrayColor];
	
	artist = [[UILabel alloc] initWithFrame:artistRect];
	artist.backgroundColor = [UIColor clearColor];
	artist.font = [UIFont boldSystemFontOfSize:12];
	artist.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
	artist.shadowOffset = CGSizeMake(0, -1);
	artist.text = @"Artist";
	artist.textAlignment = UITextAlignmentCenter;
	artist.textColor = [UIColor lightGrayColor];
	
	song = [[UILabel alloc] initWithFrame:songRect];
	song.backgroundColor = [UIColor clearColor];
	song.font = [UIFont boldSystemFontOfSize:12];
	song.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
	song.shadowOffset = CGSizeMake(0, -1);
	song.text = @"Song";
	song.textAlignment = UITextAlignmentCenter;
	song.textColor = [UIColor whiteColor];
	
	[self addSubview:album];
	[self addSubview:artist];
	[self addSubview:song];
}


- (void)dealloc {
	[album release];
	[artist release];
	[song release];
    [super dealloc];
}


@end
