//
//  ACQuestionDetailCell.h
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACUserImageView.h"
#import "BPMarkdownView.h"

@protocol ACPostCellDelegate <NSObject>

@optional
- (BOOL)userDidUpvoteQuestion:(NSString *)question;
- (BOOL)userDidUpvoteAnswer:(NSString *)answer;
- (BOOL)userDidDownvoteQuestion:(NSString *)question;
- (BOOL)userDidDownvoteAnswer:(NSString *)answer;
- (BOOL)userDidUndoQuestionUpvote:(NSString *)question;
- (BOOL)userDidUndoAnswerUpvote:(NSString *)answer;
- (BOOL)userDidUndoQuestionDownvote:(NSString *)question;
- (BOOL)userDidUndoAnswerDownvote:(NSString *)answer;
- (void)userDidSelectQuestionComments:(NSString *)question;
- (void)userDidSelectAnswerComments:(NSString *)answer;

@end

@interface ACQuestionDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downvoteButton;
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet BPMarkdownView *questionMarkdownView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userReputationLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet ACUserImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *postIDLabel;
@property (weak, nonatomic) id<ACPostCellDelegate> delegate;

- (IBAction)upvote:(id)sender;
- (IBAction)downvote:(id)sender;
- (IBAction)openComments:(id)sender;

@end
