//
//  ACTagView.h
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
@import QuartzCore;

@protocol ACTagViewDelegate <NSObject>

@optional
- (void)tagWasSelected:(NSString *)tag;
- (void)viewWasSelected;

@end

@interface ACTagView : UIView

@property (strong, nonatomic) NSArray *tagsArray;
@property (weak, nonatomic) id<ACTagViewDelegate> delegate;

@end
