//
//  ServerViewController.m
//  FirePod
//
//  Created by GamingRobot on 5/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServerViewController.h"
#import "DataManagment.h"
#import "TouchXML/TouchXML.h"

#define DATABASE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/firepod.sqlite"]
@implementation ServerViewController

//when user click fetch library button
- (IBAction) fetch_library: (id) sender
{	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	//forms are not empty put serverport and serverip into ipportmanager
	DataManagment *myManager = [DataManagment sharedDataManager];
	myManager.server_ip = serverip.text;
	myManager.server_port = serverport.text;
	
	//store ip and port in userdata
	[[NSUserDefaults standardUserDefaults] setObject:serverip.text forKey:@"server_ip"];
	[[NSUserDefaults standardUserDefaults] setObject:serverport.text forKey:@"server_port"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[serverip resignFirstResponder];
	[serverport resignFirstResponder];
	// Should be initialized with the windows frame so the HUD disables all user input by covering the entire screen
	HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	
	// Add HUD to screen
	[self.view.window addSubview:HUD];
	
	// Regisete for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	HUD.labelText = @"Loading";
	HUD.detailsLabelText = @"XML Data";
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(grabXML_putSQLITE) onTarget:self withObject:nil animated:YES];
	//[self grabXML_putSQLITE];

}

// takes song info from 
-(void) grabXML_putSQLITE {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	/*db initalazation */
	// The database is stored in the application bundle.
	NSLog(DATABASE_PATH);
	db = [FMDatabase databaseWithPath:DATABASE_PATH];
	[db setLogsErrors:TRUE];
	[db setTraceExecution:TRUE];
	[db open];
	
	/*xml fetching */
    // Initialize the blogEntries MutableArray that we declared in the header
    NSMutableArray *xmldata = [[NSMutableArray alloc] init];	
	
    // Convert the supplied URL string into a usable URL object
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%@/databases/1/items?output=xml", serverip.text, serverport.text ]];
	//NSURL *url = [NSURL URLWithString: @"http://dblog.com.au/feed/"];
	
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//dmap.listingitem" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in blogEntries
        NSMutableDictionary *blogItem = [[NSMutableDictionary alloc] init];
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
			
            // Add each field to the blogItem Dictionary with the node name as key and node value as the value
            [blogItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
		
		}
        // Add the blogItem to the global blogEntries Array so that the view can access it.
        [xmldata addObject:[blogItem copy]];
		
		
	}
	//empty database
	[db executeUpdate:@"DELETE FROM songdata"];
	for(int counter = 0; counter < [xmldata count]; counter++) {
		NSString *song_album = [[xmldata objectAtIndex: counter] objectForKey: @"daap.songalbum"];
		NSString *song_artist = [[xmldata objectAtIndex: counter] objectForKey: @"daap.songartist"];
		NSString *song_genre = [[xmldata objectAtIndex: counter] objectForKey: @"daap.songgenre"];
		NSString *song_format = [[xmldata objectAtIndex: counter] objectForKey: @"daap.songformat"];	
		NSString *song_itemname = [[xmldata objectAtIndex: counter] objectForKey: @"dmap.itemname"];
		NSString *song_tracknumber = [[xmldata objectAtIndex: counter] objectForKey: @"daap.songtracknumber"];
		NSString *song_itemid = [[xmldata objectAtIndex: counter] objectForKey: @"dmap.itemid"];
		HUD.detailsLabelText = [NSString stringWithFormat:@"Song %@", song_itemid];
		[db executeUpdate:@"insert into songdata values (?, ?, ?, ?, ?, ?, ?)", song_album, song_artist, song_genre, song_format, song_itemname, song_tracknumber, song_itemid];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
}

- (void)dealloc {
	[db close];
    [super dealloc];
}

- (void)viewDidLoad {
	//make the background have stripes
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	// Add a fetch library button 
	UIBarButtonItem *fetchButton = [[[UIBarButtonItem alloc] 
									 initWithTitle:@"Fetch Library" 
									 style:UIBarButtonItemStylePlain 
									 target:self 
									 action:@selector(fetch_library:)] autorelease]; 
	self.navigationItem.rightBarButtonItem = fetchButton; 

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	[serverip becomeFirstResponder];
	DataManagment *myManager = [DataManagment sharedDataManager];
	serverip.text = [myManager server_ip];
	serverport.text = [myManager server_port];	
}



//Note: Currently doesnt work
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
