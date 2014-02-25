//
//  ACTagView.m
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACTagView.h"

@implementation ACTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tagsArray = @[];
        [self drawTagViews];
    }
    return self;
}

- (void)drawTagViews
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    CGFloat x_val = 0;
    
    for (NSString *tagName in self.tagsArray)
    {
        UIFont *labelFont = [UIFont fontWithName:@"Verdana" size:12];
        CGSize labelSize = [tagName sizeWithAttributes:@{NSFontAttributeName: labelFont}];
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.font = labelFont;
        tagLabel.text = tagName;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView *tag = [[UIView alloc] initWithFrame:CGRectMake(x_val, 0, labelSize.width + 10, labelSize.height)];
        tag.backgroundColor = [UIColor blackColor];
        [tag addSubview:tagLabel];
        
        [self addSubview:tag];
        x_val += labelSize.width + 20;

    }
}

- (void)setTagsArray:(NSArray *)tagsArray
{
    _tagsArray = tagsArray;
    [self drawTagViews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *view = [self hitTest:location withEvent:event];
    for (UILabel *label in view.subviews)
    {
        if ([label isKindOfClass:[UILabel class]])
            if ([self.delegate respondsToSelector:@selector(tagWasSelected:)])
                [self.delegate tagWasSelected:label.text];
    }
}

@end
