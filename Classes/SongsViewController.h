//
//  SongsViewController.h
//  FirePod
//
//  Created by GamingRobot on 5/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB/FMDatabase.h"
@interface SongsViewController : UIViewController {
	IBOutlet UITableView *songsTableView;
	FMDatabase* db;
	NSMutableArray *sqlite_data;
	NSMutableArray *sqlite_id;
	NSMutableArray *sectionArray;
	NSMutableArray *alpha_array;
}
- (void) createSectionList: (id) wordArray;

@end
