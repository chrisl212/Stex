//
//  ACButton.h
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ACButton : UIButton

@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) CALayer *innerShadowLayer;

@end
