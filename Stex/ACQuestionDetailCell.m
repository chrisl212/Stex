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
    BOOL isQuestion = (self.questionTitleLabel.text.length > 0) ? YES : NO;
    if (isQuestion)
    {
        if ([self.delegate respondsToSelector:@selector(userDidDownvoteQuestion:)])
            [self.delegate userDidDownvoteQuestion:self.postIDLabel.text];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(userDidDownvoteAnswer:)])
            [self.delegate userDidDownvoteAnswer:self.postIDLabel.text];
    }
    [(UIButton *)sender setSelected:YES];
}

- (void)upvote:(id)sender
{
    BOOL isQuestion = (self.questionTitleLabel.text.length > 0) ? YES : NO;
    if (isQuestion)
    {
        if ([self.delegate respondsToSelector:@selector(userDidUpvoteQuestion:)])
            [self.delegate userDidUpvoteQuestion:self.postIDLabel.text];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(userDidUpvoteAnswer:)])
            [self.delegate userDidUpvoteAnswer:self.postIDLabel.text];
    }
    [(UIButton *)sender setSelected:YES];
}

@end
