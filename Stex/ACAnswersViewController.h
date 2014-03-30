//
//  ACAnswersViewController.h
//  Stex
//
//  Created by Chris on 2/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACAnswerCell.h"

@interface ACAnswersViewController : UITableViewController <ACPostCellDelegate>

@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSArray *answersArray;
@property (strong, nonatomic) UIImage *avatarImage;

- (id)initWithSite:(NSString *)site;

@end
