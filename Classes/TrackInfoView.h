//
//  TrackInfoView.h
//  TEST_MEDIACONTROL_APP
//
//  Created by Skylar Cantu on 2/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrackInfoView : UIView {
	UILabel		*album;
	UILabel		*artist;
	UILabel		*song;
}

@property (nonatomic, retain) UILabel *album;
@property (nonatomic, retain) UILabel *artist;
@property (nonatomic, retain) UILabel *song;

@end
