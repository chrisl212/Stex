//
//  ACUserImageView.m
//  Stex
//
//  Created by Chris on 3/2/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACUserImageView.h"

@implementation ACUserImageView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UIView *overlay = [[UIView alloc] initWithFrame:self.bounds];
    overlay.layer.opacity = 0.4;
    overlay.backgroundColor = [UIColor blackColor];
    [self addSubview:overlay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    for (UIView *candidate in self.subviews)
    {
        if ([candidate.backgroundColor isEqual:[UIColor blackColor]])
            [candidate removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserClicked" object:self.userID];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    for (UIView *candidate in self.subviews)
    {
        if ([candidate.backgroundColor isEqual:[UIColor blackColor]])
            [candidate removeFromSuperview];
    }
}

@end
