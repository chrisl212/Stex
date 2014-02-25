//
//  ACQuestionViewController.h
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACQuestionDetailCell.h"

@interface ACQuestionViewController : UITableViewController <ACQuestionDetailCellDelegate>

@property (strong, nonatomic) NSArray *answerArray;
@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSDictionary *questionInfoDictionary;

- (id)initWithQuestionID:(NSString *)question site:(NSString *)site;

@end