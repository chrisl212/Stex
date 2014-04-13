//
//  ACPostSender.h
//  Stex
//
//  Created by Chris on 4/6/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPostSender : NSObject

+ (BOOL)postQuestionWithTitle:(NSString *)title body:(NSString *)body tags:(NSArray *)tags site:(NSString *)site;
+ (BOOL)postCommentWithBody:(NSString *)body toPost:(NSString *)postID site:(NSString *)site;

@end
