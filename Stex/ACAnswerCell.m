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
    [(UIButton *)sender setSelected:YES];
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount - 1];
    if ([self.delegate respondsToSelector:@selector(userDidDownvoteAnswer:)])
        if (![self.delegate userDidDownvoteAnswer:self.postIDLabel.text])
        {
            self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
            [(UIButton *)sender setSelected:NO];
        }
}

- (void)upvote:(id)sender
{
    [(UIButton *)sender setSelected:YES];
    NSInteger voteCount = self.voteCountLabel.text.integerValue;
    self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount + 1];
    if ([self.delegate respondsToSelector:@selector(userDidUpvoteAnswer:)])
        if (![self.delegate userDidUpvoteAnswer:self.postIDLabel.text])
        {
            self.voteCountLabel.text = [NSString stringWithFormat:@"%d", voteCount];
            [(UIButton *)sender setSelected:NO];
        }
}

- (void)openComments:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userDidSelectAnswerComments:)])
        [self.delegate userDidSelectAnswerComments:self.postIDLabel.text];
}

@end
