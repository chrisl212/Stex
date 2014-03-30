//
//  ACSummaryViewController.m
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSummaryViewController.h"
#import "ACAlertView.h"
#import "ACSiteViewController.h"
#import "ACAppDelegate.h"
#import "ACInboxController.h"
#import "ACNotificationController.h"
#import "ACSettingsViewController.h"

#define rgb(x) x/255.0
#define ANIMATION_DURATION 0.5
#define SLIDING_X_VAL 620
#define SLIDING_SITE_X_VAL -620

@implementation ACSummaryViewController
{
    CGPoint originalCenter;
    CGPoint originalSlideCenter;
    CGPoint originalSiteSlideCenter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.badgeCounts = [NSMutableArray array];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideMenu:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.contentView addGestureRecognizer:swipeGestureRecognizer]; //slide in the main menu
    
    [self.avatarImageView.layer setMasksToBounds:YES]; //rounds corners of image view
    [self.avatarImageView.layer setCornerRadius:15.0]; //rounds corners of image view
    
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOut:)]; //adds button to log out on right corner of navigation bar
    [logOut setTintColor:[UIColor whiteColor]];
    [logOut setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:14]} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:logOut animated:YES];
    
    UIFont *font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:16];
    CGRect frame = CGRectMake(0, 0, [@"Stex" sizeWithAttributes:@{NSFontAttributeName : font}].width, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"Stex";
    self.navigationItem.titleView = label; //makes navigation bar's title in the correct font
    
    self.slideViewController = [[ACSlideViewController alloc] init];
    self.slideViewController.delegate = self;
    [self.view insertSubview:self.slideViewController.view atIndex:0];
    [self addChildViewController:self.slideViewController];
    
    UISwipeGestureRecognizer *slideGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideMenu:)];
    slideGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.slideViewController.view addGestureRecognizer:slideGestureRecognizer];
    
    self.siteSlideController = [[ACSiteSlideController alloc] init];
    self.siteSlideController.view.frame = self.view.bounds;
    [self.view insertSubview:self.siteSlideController.view atIndex:0];
    [self addChildViewController:self.siteSlideController];
    
    self.slideViewController.view.frame = self.view.bounds;
    
    UISwipeGestureRecognizer *siteSlideGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideSiteMenu)];
    siteSlideGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.siteSlideController.view addGestureRecognizer:siteSlideGestureRecognizer];
    
    originalCenter = self.view.center;
    originalSlideCenter = self.slideViewController.view.center;
    originalSiteSlideCenter = self.siteSlideController.view.center;
    
    [self loadFonts];
}

- (void)loadFonts
{
    UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
    titleLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:16];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:14]} forState:UIControlStateNormal];
    
    self.usernameLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:19];
    self.reputationLabel.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:17];
    
    for (UILabel *lab in self.contentView.subviews)
        if ([lab isKindOfClass:[UILabel class]] && [lab.text isEqualToString:@"Medals"])
            lab.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:17];
    
    for (UIButton *button in self.contentView.subviews)
        if ([button isKindOfClass:[UIButton class]] && [button.titleLabel.text isEqualToString:@"About..."])
            [button.titleLabel setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:15]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadFonts];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:rgb(41.0) green:rgb(75.0) blue:rgb(125.0) alpha:1.0];
    
    self.pieChart.delegate = self;
    self.pieChart.dataSource = self;
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setLabelFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:16.0]];
    [self.pieChart reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchUserInfo
{
    /* Fetch basic user info */
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me?access_token=%@&order=desc&sort=reputation&site=stackoverflow&key=XB*FUGU0f4Ju9RCNhlRQ3A((&filter=!9WgJf_Hqu", accessToken];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSData *info = [NSData dataWithContentsOfURL:requestURL];
    NSError *error;
    NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:info options:NSJSONReadingMutableLeaves error:&error];
    if (error)
        NSLog(@"%@", error);
    NSDictionary *items = [[wrapper objectForKey:@"items"] objectAtIndex:0];
    NSString *username = [items objectForKey:@"display_name"];
    
    self.siteSlideController.username = username;
    
    NSString *imageURL = [items objectForKey:@"profile_image"];
    [self.usernameLabel performSelectorOnMainThread:@selector(setText:) withObject:username waitUntilDone:NO];
    dispatch_async(dispatch_queue_create("com.a-cstudios.lazyimage", NULL), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *userImage = [UIImage imageWithData:imageData];
        [self.avatarImageView performSelectorOnMainThread:@selector(setImage:) withObject:userImage waitUntilDone:NO];
    });
    self.aboutUser = items[@"about_me"];
    
    /* Fetch total user rep and total badge count using associated accounts */
    NSString *associatedRequestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/associated?access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", accessToken];
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
    
    NSString *reputationString = [NSString stringWithFormat:@"%ld reputation", (long)finalReputation];
    [self.reputationLabel performSelectorOnMainThread:@selector(setText:) withObject:reputationString waitUntilDone:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertView dismiss];
    });
}

- (void)logOut:(id)sender
{
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *deauthenticateURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/access-tokens/%@/invalidate", accessToken];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:deauthenticateURLString]] delegate:nil];
    [conn start];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    ACAppDelegate *delegate = (ACAppDelegate *)[UIApplication sharedApplication].delegate;
    ACLoginController *loginController = [[ACLoginController alloc] initWithDelegate:delegate];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (void)displayAboutMe:(id)sender
{
    ACAlertView *alertView = [ACAlertView alertWithTitle:@"About me" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
    NSMutableAttributedString *HTMLString = [[NSMutableAttributedString alloc] initWithData:[self.aboutUser dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    [HTMLString setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:14], NSStrokeColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, HTMLString.length)];
    alertView.textView.attributedText = HTMLString;
    alertView.textView.textColor = [UIColor whiteColor];
    
    [alertView show];
}

- (void)slideMenu:(id)sender
{
    if (self.contentView.center.x != SLIDING_X_VAL)
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.siteSlideController.view.center = originalSiteSlideCenter;
            self.slideViewController.view.center = originalSlideCenter;
            self.contentView.center = CGPointMake(SLIDING_X_VAL, self.contentView.center.y);
        }];
    }
    else
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.contentView.center = originalCenter;
            self.siteSlideController.view.center = originalSiteSlideCenter;
        }];
    }
}

- (void)slideSiteMenu
{
    if (self.contentView.center.x != SLIDING_SITE_X_VAL)
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.siteSlideController.view.center = originalSiteSlideCenter;
            self.contentView.center = CGPointMake(SLIDING_SITE_X_VAL, self.contentView.center.y);
            self.slideViewController.view.center = CGPointMake(SLIDING_SITE_X_VAL, self.contentView.center.y);
        }];
    }
    else
    {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.contentView.center = originalCenter;
            self.slideViewController.view.center = originalSlideCenter;
            self.siteSlideController.view.center = originalSiteSlideCenter;
        }];
    }
}

#pragma mark - Pie Chart Delegate/Data source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.badgeCounts.count;
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    switch (index)
    {
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
    switch (index)
    {
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

#pragma mark - Slide View Delegate

- (void)siteWasSelected:(NSString *)site
{
    for (UIViewController *vc in self.childViewControllers)
    {
        if ([vc isKindOfClass:[ACSiteViewController class]])
        {
            [vc removeFromParentViewController];
            [vc.view removeFromSuperview];
        }
    }
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    ACSiteViewController *siteViewController = [[ACSiteViewController alloc] initWithSite:site];
    siteViewController.accessToken = accessToken;
    siteViewController.view.frame = self.contentView.bounds;
    [self addChildViewController:siteViewController];
    [self.contentView addSubview:siteViewController.view];
    [self slideMenu:nil];
}

- (void)userInfoCellWasSelected:(NSString *)info
{
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOut:)];
    [logOut setTintColor:[UIColor whiteColor]];
    [logOut setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:14]} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:logOut animated:YES];
    
    for (UIViewController *vc in self.childViewControllers)
    {
        if (![vc isKindOfClass:[ACSlideViewController class]] && ![vc isKindOfClass:[ACSiteSlideController class]])
        {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
    if ([info isEqualToString:@"Summary"])
        [self fetchUserInfo], [self loadFonts];
    if ([info isEqualToString:@"Inbox"])
    {
        ACInboxController *inboxController = [[ACInboxController alloc] init];
        inboxController.view.frame = self.contentView.bounds;
        [self addChildViewController:inboxController];
        [self.contentView addSubview:inboxController.view];
    }
    if ([info isEqualToString:@"Notifications"])
    {
        ACNotificationController *notificationController = [[ACNotificationController alloc] init];
        notificationController.view.frame = self.contentView.bounds;
        [self addChildViewController:notificationController];
        [self.contentView addSubview:notificationController.view];
    }
    if ([info isEqualToString:@"Settings"])
    {
        ACSettingsViewController *settingsViewController = [[ACSettingsViewController alloc] init];
        settingsViewController.view.frame = self.contentView.bounds;
        [self addChildViewController:settingsViewController];
        [self.contentView addSubview:settingsViewController.view];
    }

    [self slideMenu:nil];
}

#pragma mark -

- (void)displayUser:(NSString *)userID site:(NSString *)site
{
    /* Fetch basic user info */
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/users/%@?access_token=%@&order=desc&sort=reputation&site=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&filter=!9WgJf_Hqu", userID, accessToken, site];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    NSData *info = [NSData dataWithContentsOfURL:requestURL];
    NSError *error;
    NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:info options:NSJSONReadingMutableLeaves error:&error];
    if (error)
        NSLog(@"%@", error);
    NSDictionary *items = [[wrapper objectForKey:@"items"] objectAtIndex:0];
    NSString *username = [items objectForKey:@"display_name"];
    
    self.siteSlideController.username = username;
    
    NSString *imageURL = [items objectForKey:@"profile_image"];
    [self.usernameLabel performSelectorOnMainThread:@selector(setText:) withObject:username waitUntilDone:NO];
    dispatch_async(dispatch_queue_create("com.a-cstudios.lazyimage", NULL), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *userImage = [UIImage imageWithData:imageData];
        [self.avatarImageView performSelectorOnMainThread:@selector(setImage:) withObject:userImage waitUntilDone:NO];
    });
    self.aboutUser = items[@"about_me"];
    
    /* Fetch total user rep and total badge count using associated accounts */
    NSString *associatedRequestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/users/%@/associated?access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", userID, accessToken];
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
    
    NSString *reputationString = [NSString stringWithFormat:@"%ld reputation", (long)finalReputation];
    [self.reputationLabel performSelectorOnMainThread:@selector(setText:) withObject:reputationString waitUntilDone:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertView dismiss];
    });
    [self userInfoCellWasSelected:nil];
}

@end
