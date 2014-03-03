//
//  ACTagView.m
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACTagView.h"

#define rgb(x) x/255.0

@implementation ACTagView
{
    UILabel *selectedLabel;
}

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
    CGFloat x_val = 5.0;
    CGFloat y_val = 0.0;
    
    for (NSString *tagName in self.tagsArray)
    {
        UIFont *labelFont = [UIFont fontWithName:@"Verdana" size:12];
        CGSize labelSize = [tagName sizeWithAttributes:@{NSFontAttributeName: labelFont}];
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width + 10, labelSize.height)];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.font = labelFont;
        tagLabel.text = tagName;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        
        if (x_val + labelSize.width > self.frame.size.width)
            x_val = 5.0, y_val += labelSize.height + 7.5;
        
        UIView *tag = [[UIView alloc] initWithFrame:CGRectMake(x_val, y_val, labelSize.width + 10, labelSize.height + 2.5)];
        tag.backgroundColor = [UIColor colorWithRed:rgb(41.0) green:rgb(75.0) blue:rgb(125.0) alpha:1.0];
        [tag addSubview:tagLabel];
        
        [self addSubview:tag];
        x_val += labelSize.width + 20.0;

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
        {
            selectedLabel = label;
            
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(tagWasSelected:)])
        [self.delegate tagWasSelected:selectedLabel.text];
}

@end
