//
//  MasterViewController.m
//  TaskManager
//
//  Created by Yashwant Chauhan on 7/26/12 .
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize objects = _objects;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"DemoTaskManager";
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    
    NSLog(@"%@",[[UIApplication sharedApplication] scheduledLocalNotifications]);
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
         
    // generate random strings for list and name.
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int len = 10;
    NSMutableString *randomAlertName = [NSMutableString stringWithCapacity:len];
    for (int i=0; i<len; i++) {
        [randomAlertName appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }  
    NSMutableString *randomListName = [NSMutableString stringWithCapacity:len];
    for (int i=0; i<len; i++) {
        [randomListName appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    } 
    
    // generate random integer from 1-60 for date.
    int randomDateRange = arc4random_uniform(60) + 1;
    NSDate *fireDate = [NSDate date];

    UILocalNotification *notif = [[UILocalNotification alloc] init];
    
    // setting up UILocalNotification
    if (notif) {
        [notif setAlertBody:randomAlertName];
        [notif setFireDate:[fireDate dateByAddingTimeInterval:randomDateRange]];
        [notif setUserInfo:[NSDictionary dictionaryWithObject:randomListName forKey:@"listName"]];
        
        // The key can be anything you wish to identify your notifications with.
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notif];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"kCancel"];
    }
    
    // Adding object to array.
    // TODO: create a consistent db.
    [_objects insertObject:notif atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [notif release];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    UILocalNotification *object = [_objects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [object alertBody];    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[object fireDate]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        
        // The key can be anything you wish to identify your notifications with.
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCancel"];
        if (data) {
            UILocalNotification *localNotif = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCancel"];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    }
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
