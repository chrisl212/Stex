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
        if ([label isKindOfClass:[UITextView class]])
            [(UITextView *)label setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:label.font.pointSize]];
    }
}

- (void)downvote:(id)sender
{
    [(UIButton *)sender setSelected:YES];
    BOOL isQuestion = (self.questionTitleLabel.text.length > 0) ? YES : NO;
    
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount - 1];
    if (isQuestion)
    {
        if ([self.delegate respondsToSelector:@selector(userDidDownvoteQuestion:)])
            if (![self.delegate userDidDownvoteQuestion:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(userDidDownvoteAnswer:)])
            if (![self.delegate userDidDownvoteAnswer:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
}

- (void)upvote:(id)sender
{
    [(UIButton *)sender setSelected:YES];
    BOOL isQuestion = (self.questionTitleLabel.text.length > 0) ? YES : NO;
    
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount + 1];
    if (isQuestion)
    {
        if ([self.delegate respondsToSelector:@selector(userDidUpvoteQuestion:)])
            if (![self.delegate userDidUpvoteQuestion:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(userDidUpvoteAnswer:)])
            if (![self.delegate userDidUpvoteAnswer:self.postIDLabel.text])
            {
                self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
                [(UIButton *)sender setSelected:NO];
            }
    }
}

@end
