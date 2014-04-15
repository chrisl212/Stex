//
//  ACSummaryViewController.h
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
@import QuartzCore;
#import "XYPieChart/XYPieChart.h"
#import "ACSlideViewController.h"
#import "ACSiteSlideController.h"

@class ACAlertView;

@interface ACSummaryViewController : UIViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate, XYPieChartDataSource, XYPieChartDelegate, ACSlideControllerDelegate>
{
    @public
    BOOL isMainUser;
}

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reputationLabel;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) ACAlertView *alertView;
@property (strong, nonatomic) NSString *aboutUser;
@property (strong, nonatomic) NSMutableArray *badgeCounts;
@property (strong, nonatomic) ACSlideViewController *slideViewController;
@property (strong, nonatomic) ACSiteSlideController *siteSlideController;

- (void)displayUser:(NSString *)userID site:(NSString *)site;
- (void)logOut;
- (IBAction)displayAboutMe:(id)sender;
- (void)slideMenu;
- (void)slideSiteMenu;
- (void)fetchUserInfo;

@end
