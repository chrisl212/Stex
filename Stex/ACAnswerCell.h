//
//  ACAnswerCell.h
//  Stex
//
//  Created by Chris on 2/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACQuestionDetailCell.h"
#import "ACUserImageView.h"

@interface ACAnswerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyMarkdownView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userReputationLabel;
@property (weak, nonatomic) IBOutlet ACUserImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *postIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downvoteButton;
@property (weak, nonatomic) id<ACPostCellDelegate> delegate;

- (IBAction)upvote:(id)sender;
- (IBAction)downvote:(id)sender;
- (IBAction)openComments:(id)sender;

@end
