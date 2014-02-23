//
//  ACSummaryViewController.h
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
@import QuartzCore;
#import "ACLoginController.h"
#import "XYPieChart/XYPieChart.h"
#import "ACSlideViewController.h"
#import "ACSiteSlideController.h"

@class ACAlertView;

@interface ACSummaryViewController : UIViewController <ACLoginDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, XYPieChartDataSource, XYPieChartDelegate, ACSlideControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reputationLabel;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) ACAlertView *alertView;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *aboutUser;
@property (strong, nonatomic) NSMutableArray *badgeCounts;
@property (strong, nonatomic) ACSlideViewController *slideViewController;
@property (strong, nonatomic) ACSiteSlideController *siteSlideController;

- (IBAction)logOut:(id)sender;
- (IBAction)displayAboutMe:(id)sender;
- (IBAction)slideMenu:(id)sender;
- (void)slideSiteMenu;

@end
