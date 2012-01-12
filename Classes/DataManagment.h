//
//  DataMangment.h
//  
//
//  Created by GamingRobot on 5/3/09.
//  Copyright 2009  __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataManagment : NSObject {
	
	NSString *server_ip;
	NSString *server_port;

}
@property (readwrite, retain) NSString *server_ip;
@property (readwrite, retain) NSString *server_port;
+ (DataManagment *)sharedDataManager;
@end