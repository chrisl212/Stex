//
//  ACSiteViewController.h
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACSiteSlideController.h"
#import "ACTagView.h"

@interface ACSiteViewController : UIViewController <ACSiteSlideControllerDelegate, UITableViewDataSource, UITableViewDelegate, ACTagViewDelegate>

@property (strong, nonatomic) NSString *siteName;
@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSString *openTagName;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *questionsArray;
@property (strong, nonatomic) NSArray *avatarArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithSite:(NSString *)site;

@end
