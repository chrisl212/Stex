//
//  ACNotificationController.h
//  Stex
//
//  Created by Chris on 3/3/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;

@interface ACNotificationController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *siteAPIKey;
@property (strong, nonatomic) NSArray *notificationArray;
@property (strong, nonatomic) NSDictionary *siteIconDictionary;

- (id)initWithSite:(NSString *)siteAPIKey;

@end
