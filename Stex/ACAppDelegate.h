//
//  ACAppDelegate.h
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACLoginController.h"

@interface ACAppDelegate : UIResponder <UIApplicationDelegate, ACLoginDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *accessToken;

@end
