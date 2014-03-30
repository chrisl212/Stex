//
//  ACSlideViewController.h
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;

@protocol ACSlideControllerDelegate <NSObject>

@optional
- (void)userInfoCellWasSelected:(NSString *)info;
- (void)siteWasSelected:(NSString *)site;

@end

@interface ACSlideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *siteAPIParameters; //For future reference, the name of the site to be passed in an API request, eg. "stackoverflow".
@property (strong, nonatomic) NSArray *sitesArray;
@property (strong, nonatomic) NSArray *iconsArray;
@property (strong, nonatomic) NSMutableArray *allSites;
@property (strong, nonatomic) NSArray *userInfoCellTitles;
@property (weak, nonatomic) id<ACSlideControllerDelegate> delegate;

@end
