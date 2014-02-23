//
//  ACSiteViewController.m
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSiteViewController.h"
#import "ACAlertView.h"
#import "ACSummaryViewController.h"

@implementation ACSiteViewController

- (UIImage *)scaleToSize:(CGSize)newSize image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)initWithSite:(NSString *)site
{
    if (self = [super initWithNibName:NSStringFromClass([ACSiteViewController class]) bundle:nil])
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
        [alertView show];
        
        self.siteAPIName = site;
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.siteload", NULL), ^{
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/info?site=%@&filter=!9WgJff6fP", site];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *infoDictionary = [[wrapper objectForKey:@"items"] objectAtIndex:0];
            NSDictionary *site = [infoDictionary objectForKey:@"site"];
            
            self.siteName = [site objectForKey:@"name"];
            NSString *logoImageURLString = [site objectForKey:@"logo_url"];
            NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoImageURLString]];
            UIImage *logoImage = [UIImage imageWithData:logoData];
            
            NSString *iconImageURLString = [site objectForKey:@"icon_url"];
            NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconImageURLString]];
            UIImage *iconImage = [self scaleToSize:CGSizeMake(30, 30) image:[UIImage imageWithData:iconData]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIBarButtonItem *siteSlide = [[UIBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStyleBordered target:self action:@selector(slideSiteOptions)];
                [siteSlide setTintColor:[UIColor whiteColor]];
                self.parentViewController.navigationItem.rightBarButtonItem = siteSlide;
                
                self.siteLogoImageView.image = logoImage;
                [alertView dismiss];
            });
        });
    }
    return self;
}

- (void)slideSiteOptions
{
    ACSummaryViewController *summaryViewController = (ACSummaryViewController *)self.parentViewController;
    for (ACSiteSlideController *vc in summaryViewController.childViewControllers)
    {
        if ([vc isKindOfClass:[ACSiteSlideController class]])
        {
            vc.siteAPIName = self.siteAPIName;
            vc.delegate = self;
        }
    }
    [summaryViewController slideSiteMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Site Slide Delegate

- (void)didSelectTag:(NSString *)tag
{
    NSLog(@"%@", tag);
}

- (void)didSelectAccountArea:(NSString *)aa
{
    NSLog(@"%@", aa);
}

@end
