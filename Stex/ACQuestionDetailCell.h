//
//  ACQuestionDetailCell.h
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACQuestionDetailCellDelegate <NSObject>

@optional
- (void)userDidUpvoteQuestion:(NSString *)question;
- (void)userDidUpvoteAnswer:(NSString *)answer;
- (void)userDidDownvoteQuestion:(NSString *)question;
- (void)userDidDownvoteAnswer:(NSString *)answer;

@end

@interface ACQuestionDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *questionMarkdownView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userReputationLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *postIDLabel;
@property (weak, nonatomic) id<ACQuestionDetailCellDelegate> delegate;

- (IBAction)upvote:(id)sender;
- (IBAction)downvote:(id)sender;

@end
