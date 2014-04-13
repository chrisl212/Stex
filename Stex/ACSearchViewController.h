//
//  ACSearchViewController.h
//  Stex
//
//  Created by Chris on 4/13/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSArray *searchItems;

- (id)initWithSite:(NSString *)siteAPIName;

@end
