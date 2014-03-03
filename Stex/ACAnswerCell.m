//
//  ACAnswerCell.m
//  Stex
//
//  Created by Chris on 2/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACAnswerCell.h"

@implementation ACAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)downvote:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userDidDownvoteAnswer:)])
        [self.delegate userDidDownvoteAnswer:self.postIDLabel.text];
    [(UIButton *)sender setSelected:YES];
}

- (void)upvote:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userDidUpvoteAnswer:)])
        [self.delegate userDidUpvoteAnswer:self.postIDLabel.text];
    [(UIButton *)sender setSelected:YES];
}

@end
