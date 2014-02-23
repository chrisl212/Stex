//
//  ACSiteViewController.h
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACSiteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *siteLogoImageView;
@property (strong, nonatomic) NSString *siteName;
@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSString *accessToken;

- (id)initWithSite:(NSString *)site;

@end
