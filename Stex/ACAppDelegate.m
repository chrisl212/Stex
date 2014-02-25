//
//  ACAppDelegate.m
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACAppDelegate.h"
#import "ACAlertView.h"
#import "ACSummaryViewController.h"

@implementation ACAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    if (!self.accessToken)
    {
        ACLoginController *loginController = [[ACLoginController alloc] initWithDelegate:self];
        [(UINavigationController *)self.window.rootViewController pushViewController:loginController animated:YES];
    }
    return YES;
}

#pragma mark - Login Delegate

- (void)loginController:(ACLoginController *)controller receivedAccessCode:(NSString *)code
{
    self.accessToken = code;
    dispatch_async(dispatch_get_main_queue(), ^{
        [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:YES];
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
        [alertView show];
        ACSummaryViewController *vc = [[(UINavigationController *)self.window.rootViewController viewControllers] objectAtIndex:0];
        vc.alertView = alertView;
        dispatch_async(dispatch_queue_create("com.a-cstudios.userinfoload", NULL), ^{
            [vc fetchUserInfo];
        });
    });
}

- (void)loginController:(ACLoginController *)controller failedWithError:(NSString *)err
{
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
