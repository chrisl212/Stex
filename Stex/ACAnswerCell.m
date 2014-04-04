//
//  ACAnswerCell.m
//  Stex
//
//  Created by Chris on 2/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACAnswerCell.h"

@implementation ACAnswerCell

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
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
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
            self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
            [(UIButton *)sender setSelected:NO];
        }
    [(UIButton *)sender setSelected:YES];
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount - 1];
}

- (void)upvote:(id)sender
{
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
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
            self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
            [(UIButton *)sender setSelected:NO];
        }
    [(UIButton *)sender setSelected:YES];
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount + 1];
}

- (void)openComments:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userDidSelectAnswerComments:)])
        [self.delegate userDidSelectAnswerComments:self.postIDLabel.text];
}

@end
