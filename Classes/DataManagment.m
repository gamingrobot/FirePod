//
//  DataMangment.m
//  
//
//  Created by GamingRobot on 5/3/09.
//  Copyright 2009  __MyCompanyName__. All rights reserved.
//

#import "DataManagment.h"

static DataManagment *_sharedDataManager = nil;


@implementation DataManagment

@synthesize server_ip;
@synthesize server_port;


+ (DataManagment *)sharedDataManager
{
	if (!_sharedDataManager) {
		_sharedDataManager = [[self alloc] init];
	}
	return _sharedDataManager;
}
- (id) init
{
	self = [super init];
	if (self != nil) {
		server_ip = @"";
		server_port = @"";
	}
	return self;
}

- (void) dealloc
{
	[server_ip release];
	[server_port release];
	[super dealloc];
}


@end
