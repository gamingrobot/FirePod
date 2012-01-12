//
//  FirePodAppDelegate.h
//  FirePod
//
//  Created by GamingRobot on 4/28/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayViewController.h"

@interface FirePodAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	PlayViewController *playController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) PlayViewController *playController;

- (void)setTabOrderIfSaved;
- (void) copyDatabaseIfNeeded;
- (BOOL) getStoredIP_Port;
- (void)applicationSuspend:(struct __GSEvent *)fp8;
@end
