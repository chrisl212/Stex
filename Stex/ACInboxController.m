//
//  ACInboxController.m
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACInboxController.h"
#import "ACAppDelegate.h"
#import "ACInboxCell.h"
#import "ACQuestionViewController.h"

@implementation ACInboxController

- (UIImage *)scaleToSize:(CGSize)newSize image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)init
{
    if (self = [super init])
    {
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *accessToken = appDelegate.accessToken;
        self.inboxItemsArray = @[];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.inboxload", NULL), ^{
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/inbox?access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&site=stackoverflow&filter=!9WgJffKr8", accessToken];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
            self.inboxItemsArray = wrapper[@"items"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[ACInboxCell class] forCellReuseIdentifier:@"InboxCell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACInboxCell class]) bundle:nil] forCellReuseIdentifier:@"InboxCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.inboxItemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InboxCell";
    ACInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[ACInboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.titleLabel.text = self.inboxItemsArray[indexPath.row][@"title"];
    cell.bodyTextView.text = self.inboxItemsArray[indexPath.row][@"body"];

    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *iconURLString = [self.inboxItemsArray[indexPath.row][@"site"] objectForKey:@"icon_url"];
    NSString *APIParameter = [self.inboxItemsArray[indexPath.row][@"site"] objectForKey:@"api_site_parameter"];
    
    NSString *iconCachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_icon.png", APIParameter]];
    
    NSData *iconData;
    if (![[NSFileManager defaultManager] fileExistsAtPath:iconCachePath])
    {
        iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconURLString]];
        [[NSFileManager defaultManager] createFileAtPath:iconCachePath contents:iconData attributes:nil];
    }
    else
        iconData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:iconCachePath]];
    
    UIImage *siteIcon = [self scaleToSize:CGSizeMake(60, 60) image:[UIImage imageWithData:iconData]];
    cell.imageView.image = siteIcon;
    if (![self.inboxItemsArray[indexPath.row][@"is_unread"] boolValue])
        cell.unreadLabel.textColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *questionID = [self.inboxItemsArray[indexPath.row][@"question_id"] stringValue];
    if (!questionID)
    {
        ACQuestionViewController *questionViewController = [[ACQuestionViewController alloc] initWithAnswerID:[self.inboxItemsArray[indexPath.row][@"answer_id"] stringValue] site:self.inboxItemsArray[indexPath.row][@"site"][@"api_site_parameter"]];
        questionViewController.siteAPIName = self.inboxItemsArray[indexPath.row][@"site"][@"api_site_parameter"];
        [self.parentViewController.navigationController pushViewController:questionViewController animated:YES];
        return;
    }
    NSDictionary *dict = self.inboxItemsArray[indexPath.row];
    NSString *site = dict[@"site"][@"api_site_parameter"];
    ACQuestionViewController *questionViewController = [[ACQuestionViewController alloc] initWithQuestionID:questionID site:site];
    questionViewController.siteAPIName = site;
    [self.parentViewController.navigationController pushViewController:questionViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
