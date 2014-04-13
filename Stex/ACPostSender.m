//
//  ACPostSender.m
//  Stex
//
//  Created by Chris on 4/6/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACPostSender.h"
#import "ACAlertView.h"
#import "ACAppDelegate.h"

@implementation ACPostSender

+ (BOOL)postQuestionWithTitle:(NSString *)title body:(NSString *)body tags:(NSArray *)tags site:(NSString *)site
{
    ACAppDelegate *appDelegate = (ACAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *accessToken = appDelegate.accessToken;
    
    NSMutableString *tagString = [NSMutableString string];
    for (NSString *tag in tags)
    {
        [tagString appendFormat:@"[%@]", tag];
    }
    
    NSString *requestURLString = @"https://api.stackexchange.com/2.2/questions/add";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *questionTitle = title;
    if (questionTitle.length < 15)
    {
        [ACAlertView displayError:@"The title must be greater than 15 characters long."];
        return NO;
    }
    
    NSString *requestBody = [NSString stringWithFormat:@"key=XB*FUGU0f4Ju9RCNhlRQ3A((&access_token=%@&body=%@&tags=%@&title=%@&site=%@", accessToken, body, tagString, questionTitle, site];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *responseError;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&responseError];
    if (responseError)
    {
        [ACAlertView displayError:responseError.description];
    }
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    if ([responseDictionary.allKeys containsObject:@"error_id"])
    {
        [ACAlertView displayError:responseDictionary[@"error_message"]];
        return NO;
    }
    return YES;
}

+ (BOOL)postCommentWithBody:(NSString *)body toPost:(NSString *)postID site:(NSString *)site
{
    ACAppDelegate *appDelegate = (ACAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *accessToken = appDelegate.accessToken;
    
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/posts/%@/comments/add", postID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *requestBody = [NSString stringWithFormat:@"body=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&access_token=%@&site=%@", [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], accessToken, site];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:nil];
    return YES;
}

@end
