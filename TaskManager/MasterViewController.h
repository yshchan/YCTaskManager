//
//  MasterViewController.h
//  TaskManager
//
//  Created by Yashwant Chauhan on 7/26/12 .
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *objects;

@end
