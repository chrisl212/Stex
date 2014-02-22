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

@class ACAlertView;

@interface ACSummaryViewController : UIViewController <ACLoginDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, XYPieChartDataSource, XYPieChartDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reputationLabel;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) ACAlertView *alertView;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSMutableArray *badgeCounts;

- (IBAction)logOut:(id)sender;

@end
