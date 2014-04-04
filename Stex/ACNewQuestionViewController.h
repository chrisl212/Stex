//
//  ACNewQuestionViewController.h
//  Stex
//
//  Created by Chris on 4/3/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACTagView.h"
#import "ACAlertView.h"

@interface ACNewQuestionViewController : UITableViewController <ACTagViewDelegate, ACAlertViewDelegate>

@property (strong, nonatomic) NSString *siteAPIName;

- (id)initWithSite:(NSString *)site;

@end
