//
//  SongsViewController.m
//  FirePod
//
//  Created by GamingRobot on 5/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SongsViewController.h"
#import "PlayViewController.h"
#import "CustomCell.h"
#define DATABASE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/firepod.sqlite"]
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
//#define ALPHA_ARRAY [NSArray arrayWithObjects: @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil]


@implementation SongsViewController

// This recipe adds a title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

	if([[alpha_array objectAtIndex:section] count] != 0){
		return [NSString stringWithFormat:@"%@", [[alpha_array objectAtIndex:section] objectAtIndex:0]];
	}
	else {
		return nil;
	}	
}

// Adding a section index here
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	for(int i = 0; i < [alpha_array count]; i++){
	if([[alpha_array objectAtIndex:i] count] != 0){
		[returnArray addObject:[NSString stringWithFormat:@"%@", [[alpha_array objectAtIndex:i] objectAtIndex:0]]];
	}
	}
	return returnArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)songsTableView {
    return [sectionArray count];
}


- (NSInteger)tableView:(UITableView *)songsTableView numberOfRowsInSection:(NSInteger)section {
	return [[sectionArray objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)aTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SongName";
    NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	CustomCell *cell = (CustomCell *) [songsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
		
		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell =  (CustomCell *) currentObject;
				break;
			}
		}
	}
	
	//cell.capitalLabel.text = [stream valueForKey:@"titleNoFormatting"];
	
	NSString *songname = [[sectionArray objectAtIndex:section] objectAtIndex:row];
	NSLog(songname);
	[cell.label1 setText:songname];
	[cell.label2 setText:songname];
	
	// Set up the cell
    return cell;
}

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	[songsTableView deselectRowAtIndexPath:[songsTableView indexPathForSelectedRow] animated:YES];
	NSInteger row = [newIndexPath row];
	NSInteger section = [newIndexPath section];
	PlayViewController *playController = [[[UIApplication sharedApplication] delegate] playController];
	printf("User selected row %d\n", [newIndexPath row] + 1);
	NSString *tempval = [[sqlite_id objectAtIndex:section] objectAtIndex:row];
	NSLog(@"%d", [tempval intValue]);
	playController.row_selected = [tempval intValue];
	playController.hidesBottomBarWhenPushed = YES;
	[[self navigationController] pushViewController:playController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	[[self navigationController] setNavigationBarHidden:NO animated:NO];

}

// Build a section/row list from the alphabetically ordered word list
- (void) createSectionList: (id) wordArray
{
	// Build an array with 26 sub-array sections
	sectionArray = [[[NSMutableArray alloc] init] retain];
	sqlite_id = [[[NSMutableArray alloc] init] retain];
	alpha_array = [[[NSMutableArray alloc] init] retain];
	for (int i = 0; i < 26; i++){
		[sectionArray addObject:[[[NSMutableArray alloc] init] retain]];
		[sqlite_id addObject:[[[NSMutableArray alloc] init] retain]];
		[alpha_array addObject:[[[NSMutableArray alloc] init] retain]];

	}
	// Add each word to its alphabetical section
	for (int i = 0; i < [wordArray count]; i++)
	{
		NSString *word = [[wordArray objectAtIndex:i] objectAtIndex:0];
		if ([word length] == 0) continue;

		// determine which letter starts the name
		NSRange range = [ALPHA rangeOfString:[[word substringToIndex:1] uppercaseString]];
		[[sectionArray objectAtIndex:range.location] addObject:word];
		[[sqlite_id objectAtIndex:range.location] addObject:[[wordArray objectAtIndex:i] objectAtIndex:1]];
		[[alpha_array objectAtIndex:range.location] addObject:[word substringToIndex:1]];
	}
}


- (void) viewDidLoad {
	[super viewDidLoad];
	sqlite_data = [[NSMutableArray alloc] init];

	db = [FMDatabase databaseWithPath:DATABASE_PATH];
	[db setLogsErrors:TRUE];
	[db setTraceExecution:TRUE];
	[db open];
	
	FMResultSet *rs = [db executeQuery:@"SELECT song_itemname, song_itemid FROM songdata ORDER BY song_itemname ASC"];
	int counter = 0;
	while ([rs next]) {
		[sqlite_data addObject:[[[NSMutableArray alloc] init] retain]];
		NSString *itemname = [[rs stringForColumn:@"song_itemname"] copy];
		NSString *itemid = [[rs stringForColumn:@"song_itemid"] copy];
		NSLog(itemname);
		NSLog(itemid);
		[[sqlite_data objectAtIndex:counter] addObject:itemname];
		[[sqlite_data objectAtIndex:counter] addObject:itemid];
		[itemname release];
		[itemid release];
		counter++;
	}
	// Build the sorted section array
    [self createSectionList:sqlite_data];
	[songsTableView reloadData];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[sqlite_id release];
	[alpha_array release];
	[sectionArray release];
	[sqlite_data release];
	[db close];
    [super dealloc];
}


@end
