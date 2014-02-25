//
//  ACLoginController.m
//  Stex
//
//  Created by Chris on 2/21/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACLoginController.h"
#import "ACAlertView.h"

@interface ACLoginController ()

@property (strong, nonatomic) NSMutableData *data;

@end

@implementation ACLoginController

- (id)initWithDelegate:(id<ACLoginDelegate>)del
{
    if (self = [super init])
    {
        self.delegate = del;
        self.data = [NSMutableData data];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *requestURL = [NSURL URLWithString:@"https://stackexchange.com/oauth?client_id=2652&scope=no_expiry,write_access,private_info,read_inbox&redirect_uri=http://stex.a-cstudios.com/accept.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *path = request.URL.absoluteString;
    if ([path rangeOfString:@"stex.a-cstudios.com/accept.php?"].location != NSNotFound)
    {
        NSString *code = [[path componentsSeparatedByString:@"="] objectAtIndex:1];
        NSString *URLString = [NSString stringWithFormat:@"https://stackexchange.com/oauth/access_token?client_id=2652&client_secret=agb5xjLuhB8NmSewD1vAow((&code=%@&redirect_uri=http://stex.a-cstudios.com/accept.php", code];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
        [req setHTTPMethod:@"POST"];
        NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
        [conn start];
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ACAlertView *alert = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
        alert.textView.text = [NSString stringWithFormat:@"The request failed with error:\n%@", error];
        [alert show];
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *dataString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    if ([dataString rangeOfString:@"error"].location == NSNotFound)
    {
        if ([self.delegate respondsToSelector:@selector(loginController:receivedAccessCode:)])
            [self.delegate loginController:self receivedAccessCode:[[dataString componentsSeparatedByString:@"="] objectAtIndex:1]];
    }
    else
        if ([self.delegate respondsToSelector:@selector(loginController:failedWithError:)])
            [self.delegate loginController:self failedWithError:dataString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
