//
//  ACQuestionDetailCell.m
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACQuestionDetailCell.h"

@implementation ACQuestionDetailCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UILabel *label in self.contentView.subviews)
    {
        if ([label isKindOfClass:[UILabel class]])
            label.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:label.font.pointSize];
    }
}

- (void)downvote:(id)sender
{
    BOOL isQuestion = (self.questionTitleLabel.text.length > 0) ? YES : NO;
    
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
    if (isQuestion)
    {
        if ([sender isSelected])
        {
            if ([self.delegate respondsToSelector:@selector(userDidUndoQuestionDownvote:)])
                if ([self.delegate userDidUndoQuestionDownvote:self.postIDLabel.text])
                {
                    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount + 1];
                    [(UIButton *)sender setSelected:NO];
                    return;
                }
        }
        if ([self.delegate respondsToSelector:@selector(userDidDownvoteQuestion:)])
            if (![self.delegate userDidDownvoteQuestion:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
    else
    {
        if ([sender isSelected])
        {
            if ([self.delegate respondsToSelector:@selector(userDidUndoAnswerDownvote:)])
                if ([self.delegate userDidUndoAnswerDownvote:self.postIDLabel.text])
                {
                    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount + 1];
                    [(UIButton *)sender setSelected:NO];
                    return;
                }
        }
        if ([self.delegate respondsToSelector:@selector(userDidDownvoteAnswer:)])
            if (![self.delegate userDidDownvoteAnswer:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount - 1];
    [(UIButton *)sender setSelected:YES];
}

- (void)upvote:(id)sender
{
    BOOL isQuestion = (self.questionTitleLabel.text.length > 0) ? YES : NO;
    
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
    if (isQuestion)
    {
        if ([sender isSelected])
        {
            if ([self.delegate respondsToSelector:@selector(userDidUndoQuestionUpvote:)])
                if ([self.delegate userDidUndoQuestionUpvote:self.postIDLabel.text])
                {
                    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount - 1];
                    [(UIButton *)sender setSelected:NO];
                    return;
                }
        }
        if ([self.delegate respondsToSelector:@selector(userDidUpvoteQuestion:)])
            if (![self.delegate userDidUpvoteQuestion:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
    else
    {
        if ([sender isSelected])
        {
            if ([self.delegate respondsToSelector:@selector(userDidUndoAnswerUpvote:)])
                if ([self.delegate userDidUndoAnswerUpvote:self.postIDLabel.text])
                {
                    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount - 1];
                    [(UIButton *)sender setSelected:NO];
                    return;
                }
        }
        if ([self.delegate respondsToSelector:@selector(userDidUpvoteAnswer:)])
            if (![self.delegate userDidUpvoteAnswer:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount + 1];
    [(UIButton *)sender setSelected:YES];
}

- (void)openComments:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userDidSelectQuestionComments:)])
        [self.delegate userDidSelectQuestionComments:self.postIDLabel.text];
}

@end
