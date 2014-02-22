//
//  ACLoginController.h
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACLoginController;

@protocol ACLoginDelegate <NSObject>

@optional
- (void)loginController:(ACLoginController *)controller receivedAccessCode:(NSString *)code;
- (void)loginController:(ACLoginController *)controller failedWithError:(NSString *)err;

@end

@interface ACLoginController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) id<ACLoginDelegate> delegate;

- (id)initWithDelegate:(id<ACLoginDelegate>)del;

@end
