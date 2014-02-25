//
//  ACQuestionViewController.m
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACQuestionViewController.h"
#import "MMMarkdown.h"
#import "ACAppDelegate.h"

#define QUESTION_SECTION 0
#define ANSWER_SECTION 1

@implementation ACQuestionViewController

- (UIImage *)imageWithContentsOfURL:(NSURL *)url
{
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:imageData];
}

- (id)initWithQuestionID:(NSString *)question site:(NSString *)site
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.answerArray = @[];
        [self.tableView registerClass:[ACQuestionDetailCell class] forCellReuseIdentifier:@"QuestionCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionDetailCell class]) bundle:nil] forCellReuseIdentifier:@"QuestionCell"];
        [self.tableView registerClass:[ACQuestionDetailCell class] forCellReuseIdentifier:@"AnswerCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionDetailCell class]) bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.questionload", NULL), ^{
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%@?order=desc&sort=activity&site=%@&filter=!9WgJfj3zM&key=XB*FUGU0f4Ju9RCNhlRQ3A((", question, site];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *items = [[wrapper objectForKey:@"items"] objectAtIndex:0];
            NSMutableDictionary *questionInfo = [NSMutableDictionary dictionary];
            
            NSDictionary *ownerInfo = [items objectForKey:@"owner"];
            [questionInfo setObject:[ownerInfo objectForKey:@"display_name"] forKey:@"username"];
            [questionInfo setObject:[self imageWithContentsOfURL:[NSURL URLWithString:[ownerInfo objectForKey:@"profile_image"]]] forKey:@"avatar"];
            [questionInfo setObject:[ownerInfo objectForKey:@"reputation"] forKey:@"reputation"];
            
            [questionInfo setObject:[items objectForKey:@"is_answered"] forKey:@"answered"];
            [questionInfo setObject:[items objectForKey:@"view_count"] forKey:@"views"];
            [questionInfo setObject:[items objectForKey:@"score"] forKey:@"votes"];
            [questionInfo setObject:[items objectForKey:@"body_markdown"] forKey:@"body"];
            [questionInfo setObject:[items objectForKey:@"title"] forKey:@"title"];
            [questionInfo setObject:[items objectForKey:@"question_id"] forKey:@"question_id"];
            self.questionInfoDictionary = [NSDictionary dictionaryWithDictionary:questionInfo];
            
            NSMutableArray *answerArray = [NSMutableArray array];
            NSString *answersRequestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%@/answers?site=%@&order=desc&sort=activity&filter=!9WgJfjxe6&key=XB*FUGU0f4Ju9RCNhlRQ3A((", question, site];
            NSData *answersRequestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:answersRequestURLString]];
            NSDictionary *answersWrapper = [NSJSONSerialization JSONObjectWithData:answersRequestData options:NSJSONReadingMutableLeaves error:nil];
            for (NSDictionary *answerDictionary in answersWrapper[@"items"])
            {
                NSMutableDictionary *modifiedDictionary = [NSMutableDictionary dictionaryWithDictionary:answerDictionary];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:answerDictionary[@"owner"][@"profile_image"]]];
                modifiedDictionary[@"avatar"] = [UIImage imageWithData:imageData];
                [answerArray addObject:modifiedDictionary];
            }
            self.answerArray = [NSArray arrayWithArray:answerArray];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 375;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == QUESTION_SECTION && self.questionInfoDictionary)
        return 1;
    return self.answerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == QUESTION_SECTION)
    {
        static NSString *questionCellID = @"QuestionCell";
        ACQuestionDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:questionCellID forIndexPath:indexPath];
        if (!cell)
            cell = [[ACQuestionDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:questionCellID];
        cell.questionTitleLabel.text = self.questionInfoDictionary[@"title"];
        cell.usernameLabel.text = self.questionInfoDictionary[@"username"];
        cell.userAvatarImageView.image = self.questionInfoDictionary[@"avatar"];
        cell.userReputationLabel.text = [self.questionInfoDictionary[@"reputation"] stringValue];
        cell.viewsLabel.text = [NSString stringWithFormat:@"%@ views", self.questionInfoDictionary[@"views"]];
        cell.voteCountLabel.text = [self.questionInfoDictionary[@"votes"] stringValue];
        cell.postIDLabel.text = [self.questionInfoDictionary[@"question_id"] stringValue];
        if ([self.questionInfoDictionary[@"answered"] boolValue])
            cell.voteCountLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
        else
            cell.voteCountLabel.textColor = [UIColor blackColor];
        
        NSString *markdownText = self.questionInfoDictionary[@"body"];
        NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdownText error:nil];
        cell.questionMarkdownView.scrollView.bounces = NO;
        [cell.questionMarkdownView loadHTMLString:htmlString baseURL:nil];
        
        cell.delegate = self;
        return cell;
    }
    static NSString *answerCellID = @"AnswerCell";
    
    NSDictionary *answerDictionary = self.answerArray[indexPath.row];
    ACQuestionDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:answerCellID forIndexPath:indexPath];
    if (!cell)
        cell = [[ACQuestionDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:answerCellID];
    cell.questionTitleLabel.text = @"";
    cell.usernameLabel.text = [answerDictionary[@"owner"] objectForKey:@"display_name"];
    cell.userAvatarImageView.image = answerDictionary[@"avatar"];
    cell.userReputationLabel.text = [answerDictionary[@"owner"][@"reputation"] stringValue];
    cell.viewsLabel.text = @"";
    cell.voteCountLabel.text = [answerDictionary[@"score"] stringValue];
    cell.postIDLabel.text = [answerDictionary[@"answer_id"] stringValue];
    if ([answerDictionary[@"is_accepted"] boolValue])
        cell.voteCountLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
    else
        cell.voteCountLabel.textColor = [UIColor blackColor];
    
    NSString *markdownText = answerDictionary[@"body_markdown"];
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdownText error:nil];
    cell.questionMarkdownView.scrollView.bounces = NO;
    [cell.questionMarkdownView loadHTMLString:htmlString baseURL:nil];
    cell.delegate = self;
    return cell;
}

#pragma mark - ACQuestionDetailCellDelegate

- (void)vote:(NSString *)postID postType:(NSString *)postType voteType:(NSString *)vote
{
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/%@/%@/%@",postType, postID, vote];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    
    NSString *body = [NSString stringWithFormat:@"access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&site=%@", accessToken, self.siteAPIName];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}

- (void)userDidDownvoteAnswer:(NSString *)answer
{
    [self vote:answer postType:@"answers" voteType:@"downvote"];
}

- (void)userDidDownvoteQuestion:(NSString *)question
{
    [self vote:question postType:@"questions" voteType:@"downvote"];
}

- (void)userDidUpvoteAnswer:(NSString *)answer
{
    [self vote:answer postType:@"answers" voteType:@"upvote"];
}

- (void)userDidUpvoteQuestion:(NSString *)question
{
    [self vote:question postType:@"questions" voteType:@"upvote"];
}

@end
