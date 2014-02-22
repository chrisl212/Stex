//
//  ACSummaryViewController.m
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSummaryViewController.h"
#import "ACAlertView.h"

#define rgb(x) x/255.0

@implementation ACSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.badgeCounts = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:rgb(63.0) green:rgb(105.0) blue:rgb(179.0) alpha:1.0];
    
    self.pieChart.delegate = self;
    self.pieChart.dataSource = self;
    [self.pieChart setShowPercentage:YES];
    [self.pieChart setLabelFont:[UIFont fontWithName:@"Verdana" size:16.0]];
    [self.pieChart reloadData];
    
    if (!self.accessToken)
    {
        ACLoginController *loginController = [[ACLoginController alloc] initWithDelegate:self];
        [self presentViewController:loginController animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchUserInfo
{
    /* Fetch basic user info */
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me?access_token=%@&order=desc&sort=reputation&site=stackoverflow&key=XB*FUGU0f4Ju9RCNhlRQ3A((", self.accessToken];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSData *info = [NSData dataWithContentsOfURL:requestURL];
    NSError *error;
    NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:info options:NSJSONReadingMutableLeaves error:&error];
    if (error)
        NSLog(@"%@", error);
    NSDictionary *items = [[wrapper objectForKey:@"items"] objectAtIndex:0];
    NSString *username = [items objectForKey:@"display_name"];
    NSString *imageURL = [items objectForKey:@"profile_image"];
    [self.usernameLabel performSelectorOnMainThread:@selector(setText:) withObject:username waitUntilDone:NO];
    dispatch_async(dispatch_queue_create("com.a-cstudios.lazyimage", NULL), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *userImage = [UIImage imageWithData:imageData];
        [self.avatarImageView performSelectorOnMainThread:@selector(setImage:) withObject:userImage waitUntilDone:NO];
    });
    
    /* Fetch total user rep using associated accounts */
    NSString *associatedRequestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/associated?access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", self.accessToken];
    NSData *associatedInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:associatedRequestURLString]];
    NSDictionary *associatedWrapper = [NSJSONSerialization JSONObjectWithData:associatedInfo options:NSJSONReadingMutableLeaves error:nil];
    NSArray *allAccounts = [associatedWrapper objectForKey:@"items"];
    NSInteger finalReputation = 0;
    NSInteger goldCount, bronzeCount, silverCount;
    goldCount = 0;
    bronzeCount = 0;
    silverCount = 0;
    for (NSDictionary *accountDictionary in allAccounts)
    {
        NSNumber *rep = [accountDictionary objectForKey:@"reputation"];
        finalReputation += rep.integerValue;
        
        NSNumber *bronze = [[accountDictionary objectForKey:@"badge_counts"] objectForKey:@"bronze"];
        NSNumber *silver = [[accountDictionary objectForKey:@"badge_counts"] objectForKey:@"silver"];
        NSNumber *gold = [[accountDictionary objectForKey:@"badge_counts"] objectForKey:@"gold"];
        bronzeCount += bronze.integerValue;
        silverCount += silver.integerValue;
        goldCount += gold.integerValue;
    }
    self.badgeCounts = [NSMutableArray arrayWithArray:@[[NSNumber numberWithInteger:bronzeCount], [NSNumber numberWithInteger:silverCount], [NSNumber numberWithInteger:goldCount]]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pieChart reloadData];
    });
    
    NSString *reputationString = [NSString stringWithFormat:@"%d reputation", finalReputation];
    [self.reputationLabel performSelectorOnMainThread:@selector(setText:) withObject:reputationString waitUntilDone:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertView dismiss];
    });
}

- (void)logOut:(id)sender
{
    NSString *deauthenticateURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/access-tokens/%@/invalidate", self.accessToken];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:deauthenticateURLString]] delegate:nil];
    [conn start];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    ACLoginController *loginController = [[ACLoginController alloc] initWithDelegate:self];
    [self presentViewController:loginController animated:YES completion:nil];
}

#pragma mark - Login Delegate

- (void)loginController:(ACLoginController *)controller receivedAccessCode:(NSString *)code
{
    self.accessToken = code;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        self.alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
        [self.alertView show];
    });
    [self fetchUserInfo];
}

- (void)loginController:(ACLoginController *)controller failedWithError:(NSString *)err
{
    
}

#pragma mark - Pie Chart Delegate/Data source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.badgeCounts.count;
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return @"Bronze";
            break;
            
        case 1:
            return @"Silver";
            break;
            
        case 2:
            return @"Gold";
            break;
            
        default:
            break;
    }
    return @"Error";
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [self.badgeCounts[index] integerValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return [UIColor colorWithRed:rgb(205.0) green:rgb(127.0) blue:rgb(50.0) alpha:1.0];
            break;
            
        case 1:
            return [UIColor colorWithRed:rgb(204.0) green:rgb(204.0) blue:rgb(204.0) alpha:1.0];
            break;
            
        case 2:
            return [UIColor yellowColor];
            break;
            
        default:
            break;
    }
    return [UIColor whiteColor];
}

@end
