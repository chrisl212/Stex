//
//  ACButton.m
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#define G1_COLOR 225.0/255.0
#define G2_COLOR 200.0/255.0

#import "ACButton.h"

@implementation ACButton

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 8;
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.gradientLayer = [CAGradientLayer layer];
    [self.gradientLayer setFrame:rect];
    self.gradientLayer.colors = @[(id)[UIColor colorWithRed:G1_COLOR green:G1_COLOR blue:G1_COLOR alpha:1.0].CGColor, (id)[UIColor colorWithRed:G2_COLOR green:G2_COLOR blue:G2_COLOR alpha:1.0].CGColor];
    self.gradientLayer.locations = @[@0.0, @1.0];
    self.gradientLayer.startPoint = CGPointMake(CGRectGetMidX(rect), 0);
    self.gradientLayer.endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    self.gradientLayer.cornerRadius = 8;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

@end
