//
//  ACCommentsViewController.m
//  Stex
//
//  Created by Chris on 3/30/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACCommentsViewController.h"
#import "ACCommentCell.h"
#import "ACAppDelegate.h"
#import "ACAlertView.h"

#define NEW_COMMENT_SECTION 0
#define COMMENTS_SECTION 1

@implementation ACCommentsViewController

- (id)initWithPostID:(NSString *)postID isQuestion:(BOOL)question site:(NSString *)site
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.siteAPIName = site;
        self.postID = postID;
        
        NSString *postTypeString = @"answers";
        if (question)
            postTypeString = @"questions";
        
        NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/%@/%@/comments?order=desc&sort=creation&site=%@&filter=!9WgJfngld&key=XB*FUGU0f4Ju9RCNhlRQ3A((", postTypeString, postID, site];
        NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
        NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *items = wrapper[@"items"];
        self.commentArray = [NSArray arrayWithArray:items];
        
        [self.tableView registerClass:[ACCommentCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ACCommentCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        [self.tableView registerClass:[ACCommentCell class] forCellReuseIdentifier:@"NewCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ACCommentCell" bundle:nil] forCellReuseIdentifier:@"NewCell"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == NEW_COMMENT_SECTION && indexPath.row == 1)
        return 44.0;
    return 122.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == NEW_COMMENT_SECTION)
        return 2;
    return self.commentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == NEW_COMMENT_SECTION)
    {
        if (indexPath.row == 0)
        {
            static NSString *cellID = @"NewCell";
            ACCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            cell.bodyTextView.editable = YES;
            cell.bodyTextView.text = @"New comment";
            cell.usernameLabel.text = @"You";
            return cell;
        }
        static NSString *cellID = @"SubmitCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.text = @"Submit";
        return cell;
    }
    static NSString *CellIdentifier = @"Cell";
    ACCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *commentDictionary = self.commentArray[indexPath.row];
    cell.usernameLabel.text = commentDictionary[@"owner"][@"display_name"];
    
    NSNumber *rawDate = commentDictionary[@"creation_date"];
    NSDate *creationDate = [NSDate dateWithTimeIntervalSince1970:rawDate.doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    cell.dateLabel.text = [formatter stringFromDate:creationDate];
    cell.bodyTextView.text = commentDictionary[@"body"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == NEW_COMMENT_SECTION)
    {
        if (indexPath.row == 1)
        {
            NSIndexPath *newCommentCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:NEW_COMMENT_SECTION];
            ACCommentCell *commentCell = (ACCommentCell *)[tableView cellForRowAtIndexPath:newCommentCellIndexPath];
            [commentCell.bodyTextView resignFirstResponder];
            NSString *commentBody = commentCell.bodyTextView.text;
            if (commentBody.length < 15)
            {
                ACAlertView *alertView = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
                alertView.textView.text = @"A comment's body must be at least 15 characters.";
                [alertView show];
                return;
            }
            
            NSString *accessToken = [(ACAppDelegate *)[[UIApplication sharedApplication] delegate] accessToken];
            
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/posts/%@/comments/add?body=%@&access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&site=%@", self.postID, [commentBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], accessToken, self.siteAPIName];
            [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

@end
