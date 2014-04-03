//
//  ACCommentCell.h
//  Stex
//
//  Created by Chris on 3/30/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACCommentCell;

@protocol ACCommentDelegate <NSObject>

@optional
- (void)commentWasFlagged:(ACCommentCell *)comment;
- (void)commentWasDeleted:(ACCommentCell *)comment;

@end

@interface ACCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *flagCommentButton;
@property (strong, nonatomic) NSString *commentID;
@property (weak, nonatomic) id<ACCommentDelegate> delegate;

- (IBAction)deleteComment:(id)sender;
- (IBAction)flagComment:(id)sender;

@end
