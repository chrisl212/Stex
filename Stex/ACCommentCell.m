//
//  ACCommentCell.m
//  Stex
//
//  Created by Chris on 3/30/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACCommentCell.h"

@implementation ACCommentCell

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

@end
