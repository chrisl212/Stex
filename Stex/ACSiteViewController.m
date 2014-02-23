//
//  ACSiteViewController.m
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSiteViewController.h"
#import "ACAlertView.h"

@implementation ACSiteViewController

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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.siteLogoImageView.image = logoImage;
                [alertView dismiss];
            });
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
