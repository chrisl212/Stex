//
//  ACCommentsViewController.h
//  Stex
//
//  Created by Chris on 3/30/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCommentCell.h"

@interface ACCommentsViewController : UITableViewController <ACCommentDelegate>

@property (strong, nonatomic) NSArray *commentArray;
@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSString *postID;

- (id)initWithPostID:(NSString *)postID isQuestion:(BOOL)question site:(NSString *)site;

@end
