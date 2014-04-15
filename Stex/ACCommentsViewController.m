//
//  ACCommentsViewController.m
//  Stex
//
//  Created by Chris on 3/30/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACCommentsViewController.h"
#import "ACAppDelegate.h"
#import "ACAlertView.h"
#import "ACPostSender.h"
#import "Bypass.h"
#import "NSString+HTML.h"

#define NEW_COMMENT_SECTION 0
#define COMMENTS_SECTION 1

@implementation ACCommentsViewController
{
    BOOL isQuestion;
}

- (id)initWithPostID:(NSString *)postID isQuestion:(BOOL)question site:(NSString *)site
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        
        [self.tableView registerClass:[ACCommentCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ACCommentCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        [self.tableView registerClass:[ACCommentCell class] forCellReuseIdentifier:@"NewCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ACCommentCell" bundle:nil] forCellReuseIdentifier:@"NewCell"];
        
        if (!site)
        {
            ACAlertView *errorAlert = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
            errorAlert.textView.text = @"The site parameter was nil; error loading data.";
            [errorAlert show];
            self.commentArray = @[];
            return self;
        }
        self.siteAPIName = site;
        self.postID = postID;
        isQuestion = question;
        [self loadComments];
    }
    return self;
}

- (void)loadComments
{
    NSString *postTypeString = @"answers";
    if (isQuestion)
        postTypeString = @"questions";
    
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/%@/%@/comments?order=desc&sort=creation&site=%@&filter=!9WgJfnTX4&key=XB*FUGU0f4Ju9RCNhlRQ3A((", postTypeString, self.postID, self.siteAPIName];
    NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
    
    if (!requestData)
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
        [alertView show];
        return;
    }
    
    NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *items = wrapper[@"items"];
    self.commentArray = [NSArray arrayWithArray:items];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UITextView appearance] setTintColor:[UIColor blueColor]];
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
    if (indexPath.section == NEW_COMMENT_SECTION && indexPath.row == 0)
        return 112.0;
    
    NSDictionary *commentDictionary = self.commentArray[indexPath.row];
    
    NSString *markdownText = commentDictionary[@"body_markdown"];
    
    BPParser *parser = [[BPParser alloc] init];
    BPDocument *document = [parser parse:markdownText];
    BPAttributedStringConverter *converter = [[BPAttributedStringConverter alloc] init];
    NSAttributedString *markdownString = [converter convertDocument:document];
    
    UIFont *font = [markdownString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    CGRect rectSize = [markdownString.string boundingRectWithSize:CGSizeMake(320.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:NULL];
    
    CGFloat height = MAX(rectSize.size.height, 133.0);
    
    return height;
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
    NSString *userID = [(ACAppDelegate *)[UIApplication sharedApplication].delegate userID];
    
    NSDictionary *commentDictionary = self.commentArray[indexPath.row];
    cell.usernameLabel.text = commentDictionary[@"owner"][@"display_name"];
    
    NSNumber *rawDate = commentDictionary[@"creation_date"];
    NSDate *creationDate = [NSDate dateWithTimeIntervalSince1970:rawDate.doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    cell.dateLabel.text = [formatter stringFromDate:creationDate];
    
    NSString *markdownText = commentDictionary[@"body_markdown"];
    markdownText = [markdownText stringByDecodingHTMLEntities];
    
    BPParser *parser = [[BPParser alloc] init];
    BPDocument *document = [parser parse:markdownText];
    BPAttributedStringConverter *converter = [[BPAttributedStringConverter alloc] init];
    NSAttributedString *markdownString = [converter convertDocument:document];
    
    cell.bodyTextView.attributedText = markdownString;
    
    cell.commentID = [commentDictionary[@"comment_id"] stringValue];
    cell.delegate = self;
    if ([[commentDictionary[@"owner"][@"user_id"] stringValue] isEqualToString:userID])
        cell.deleteCommentButton.hidden = NO;
    else
        cell.deleteCommentButton.hidden = YES;
    
    return cell;
}

- (void)commentWasDeleted:(ACCommentCell *)comment
{
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/comments/34813823/delete"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *requestBody = [NSString stringWithFormat:@"id=%@&access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&site=%@", comment.commentID, accessToken, self.siteAPIName];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:comment];
    
    NSMutableArray *temporary = self.commentArray.mutableCopy;
    [temporary removeObjectAtIndex:indexPath.row];
    self.commentArray = [NSArray arrayWithArray:temporary];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)commentWasFlagged:(ACCommentCell *)comment
{
    NSLog(@"comment was flagged");
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
            
            NSString *userID = [(ACAppDelegate *)[[UIApplication sharedApplication] delegate] userID];
            
            [ACPostSender postCommentWithBody:commentBody toPost:self.postID site:self.siteAPIName];
            
            NSMutableArray *temp = self.commentArray.mutableCopy;
            NSDictionary *comment = @{@"owner": @{@"display_name": @"You", @"user_id": @([userID integerValue])}, @"creation_date": @([[NSDate date] timeIntervalSince1970]), @"body_markdown": commentBody, @"comment_id": @(00000)};
            [temp addObject:comment];
            self.commentArray = [NSArray arrayWithArray:temp];
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:COMMENTS_SECTION]] withRowAnimation:UITableViewRowAnimationRight];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

@end
