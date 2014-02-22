//
//  ACViewController.m
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACViewController.h"

@implementation ACViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma mark - Login Delegate

- (void)loginController:(ACLoginController *)controller receivedAccessCode:(NSString *)code
{
    self.accessToken = code;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)loginController:(ACLoginController *)controller failedWithError:(NSString *)err
{
    
}

@end
