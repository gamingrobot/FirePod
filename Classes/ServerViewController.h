//
//  ServerViewController.h
//  FirePod
//
//  Created by GamingRobot on 5/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB/FMDatabase.h"
#import "MBProgressHUD.h"

@interface ServerViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate> {
	IBOutlet UITextField *serverip;
	IBOutlet UITextField *serverport;
	FMDatabase* db;
	MBProgressHUD *HUD;	
}
-(void) grabXML_putSQLITE;
@end
