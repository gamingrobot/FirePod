//
//  FirePodAppDelegate.m
//  FirePod
//
//  Created by GamingRobot on 4/28/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FirePodAppDelegate.h"
#import "DataManagment.h"
#define DATABASE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/firepod.sqlite"]

@implementation FirePodAppDelegate
@synthesize playController;
@synthesize window;
@synthesize tabBarController;
//to supsend main thread
//[ [ NSThread: mainThread ] sleepForTimeInterval:(NSTimeInterval)ti ]

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//[[[tabBarController.viewControllers objectAtIndex:0] navigationBar] setTintColor:[UIColor colorWithRed:.02 green:.29 blue:.02 alpha:0.0]];
	for (int i = 1 ; i < 4 ; i++) {
		//[[[tabBarController.viewControllers objectAtIndex:i] navigationBar] setTintColor:[UIColor colorWithRed:.02 green:.29 blue:.02 alpha:.3]];
	}
	playController = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
	//pass stored server data to the ipportmanager
	BOOL displayErrorBool = [self getStoredIP_Port];
	if (displayErrorBool == TRUE)
	{
		UIAlertView *serverAlert = [[UIAlertView alloc]
								  initWithTitle:@"No Server Set" message:@"You must go to the more tab to set up the server connection"
								  delegate:self cancelButtonTitle:nil
								  otherButtonTitles:@"OK", nil];
		[serverAlert show];
		[serverAlert release];
	}
	//load tab order from saved settings
	[self setTabOrderIfSaved];
	
	//Copy database to the user's phone if needed.
	[self copyDatabaseIfNeeded];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
}

- (void)applicationSuspend:(struct __GSEvent *)fp8
{
	
}


- (void)applicationWillTerminate:(UIApplication *)application {
	//store tab order in NSUserDefaults
	NSMutableArray *savedOrder = [NSMutableArray arrayWithCapacity:6];
	NSArray *tabOrderToSave = tabBarController.viewControllers;
	
	for (UIViewController *aViewController in tabOrderToSave) {
		[savedOrder addObject:aViewController.tabBarItem.title];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:savedOrder forKey:@"savedTabOrder"];
}

- (void)setTabOrderIfSaved {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedOrder = [defaults arrayForKey:@"savedTabOrder"];
	NSMutableArray *orderedTabs = [NSMutableArray arrayWithCapacity:6];
	if ([savedOrder count] > 0 ) {
		for (int i = 0; i < [savedOrder count]; i++){
			for (UIViewController *aController in tabBarController.viewControllers) {
				if ([aController.tabBarItem.title isEqualToString:[savedOrder objectAtIndex:i]]) {
					[orderedTabs addObject:aController];
				}
			}
		}
		tabBarController.viewControllers = orderedTabs;
	}
}


- (void) copyDatabaseIfNeeded {
	
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = DATABASE_PATH;
	NSLog(dbPath);
	BOOL success = [fileManager fileExistsAtPath:dbPath]; 
	
	if(!success) {
		
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"firepod.sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success) 
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}	
}




- (BOOL) getStoredIP_Port {
	DataManagment *myManager = [DataManagment sharedDataManager];
	NSString *server_ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_ip"];
	NSString *server_port = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_port"];
	if(server_ip != nil || server_port != nil){
		NSLog(server_ip);
		myManager.server_ip = server_ip;
		myManager.server_port  = server_port;
		NSLog(myManager.server_ip);
		return FALSE;
	}	
	else{
		return TRUE;
	}

	
}	

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[playController release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

