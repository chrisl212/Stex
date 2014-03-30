//
//  ACNotificationController.m
//  Stex
//
//  Created by Chris on 3/3/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACNotificationController.h"
#import "ACAppDelegate.h"

#define FONT_SIZE 14.0

@implementation ACNotificationController

- (id)init
{
    return [self initWithSite:@"stackoverflow"];
}

- (id)initWithSite:(NSString *)siteAPIKey
{
    if (self = [super init])
    {
        self.siteAPIKey = siteAPIKey;
        self.notificationArray = @[];
        self.siteIconDictionary = @{};
        [self fetchNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height - 44) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (UIImage *)scaleToSize:(CGSize)newSize image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)fetchNotifications
{
    dispatch_async(dispatch_queue_create("com.a-cstudios.notifload", NULL), ^{
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *accessToken = appDelegate.accessToken;
        NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/notifications?site=%@&access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", self.siteAPIKey, accessToken];
        NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
        NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *items = wrapper[@"items"];
        
        NSMutableDictionary *siteIconDictionary = [NSMutableDictionary dictionary];
        for (NSDictionary *siteDictionary in items)
        {
            NSString *siteAPIName = siteDictionary[@"site"][@"api_site_parameter"];
            if (!siteIconDictionary[siteAPIName])
            {
                NSString *iconRequestURLString = siteDictionary[@"site"][@"icon_url"];
                NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconRequestURLString]];
                UIImage *iconImage = [UIImage imageWithData:iconData];
                iconImage = [self scaleToSize:CGSizeMake(40, 40) image:iconImage];
                siteIconDictionary[siteAPIName] = iconImage;
            }
        }
        self.siteIconDictionary = [NSDictionary dictionaryWithDictionary:siteIconDictionary];
        self.notificationArray = items;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table View Delegate / Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notificationDictionary = self.notificationArray[indexPath.row];
    NSAttributedString *attributedBodyString = [[NSAttributedString alloc] initWithString:notificationDictionary[@"body"] attributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}];
    
    CGRect rectSize = [attributedBodyString.string boundingRectWithSize:CGSizeMake(260.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:FONT_SIZE]} context:NULL];
    
    CGFloat height = MAX(rectSize.size.height, 44.0f);
    
    return height + (5.0 * 2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notificationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UILabel *label = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:0];
        [label setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:FONT_SIZE]];
        [label setTag:1];
        
        [[cell contentView] addSubview:label];
    }
    
    NSDictionary *notificationDictionary = self.notificationArray[indexPath.row];
    NSAttributedString *attributedBodyString = [[NSAttributedString alloc] initWithString:notificationDictionary[@"body"] attributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}];
    
    CGRect bodySize = [attributedBodyString.string boundingRectWithSize:CGSizeMake(260.0, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"Font"] size:FONT_SIZE]}
                                         context:nil];
    if (!label)
        label = (UILabel *)[cell viewWithTag:1];
    
    [label setText:attributedBodyString.string];
    [label setFrame:CGRectMake(60.0, 5.0, 260.0, MAX(bodySize.size.height, 44.0f))];
    
    
    cell.imageView.image = self.siteIconDictionary[notificationDictionary[@"site"][@"api_site_parameter"]];
    return cell;
}

@end
