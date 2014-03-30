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
#import "ACAlertView.h"
#import "ACAnswerCell.h"
#import "ACSummaryViewController.h"

#define QUESTION_SECTION 0
#define ANSWER_SECTION 1

@implementation ACQuestionViewController

- (UIImage *)imageWithContentsOfURL:(NSURL *)url
{
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:imageData];
}

- (id)initWithAnswerID:(NSString *)answer site:(NSString *)site
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.answerArray = @[];
        [self.tableView registerClass:[ACQuestionDetailCell class] forCellReuseIdentifier:@"QuestionCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionDetailCell class]) bundle:nil] forCellReuseIdentifier:@"QuestionCell"];
        
        [self.tableView registerClass:[ACAnswerCell class] forCellReuseIdentifier:@"AnswerCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACAnswerCell class]) bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.answerload", NULL), ^{
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/answers/%@?order=desc&sort=activity&site=%@&filter=!9WgJfj3zM&key=XB*FUGU0f4Ju9RCNhlRQ3A((", answer, site];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *items = [[wrapper objectForKey:@"items"] objectAtIndex:0];

            id o = [self initWithQuestionID:[items[@"question_id"] stringValue] site:site];
            o = nil;
        });
    }
    return self;
}

- (id)initWithQuestionID:(NSString *)question site:(NSString *)site
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.answerArray = @[];
        [self.tableView registerClass:[ACQuestionDetailCell class] forCellReuseIdentifier:@"QuestionCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionDetailCell class]) bundle:nil] forCellReuseIdentifier:@"QuestionCell"];
        
        [self.tableView registerClass:[ACAnswerCell class] forCellReuseIdentifier:@"AnswerCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACAnswerCell class]) bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.questionload", NULL), ^{
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%@?order=desc&sort=activity&site=%@&filter=!9WgJfj3zM&key=XB*FUGU0f4Ju9RCNhlRQ3A((", question, site];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
            if (!wrapper[@"items"] || !wrapper || [wrapper[@"items"] count] == 0)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    ACAlertView *alertView = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
                    alertView.textView.text = @"An error occured loading the data";
                    [alertView show];
                });
                return;
            }
            NSDictionary *items = [[wrapper objectForKey:@"items"] objectAtIndex:0];
            NSMutableDictionary *questionInfo = [NSMutableDictionary dictionary];
            
            NSDictionary *ownerInfo = [items objectForKey:@"owner"];
            if ([ownerInfo[@"user_type"] isEqualToString:@"does_not_exist"])
            {
                questionInfo[@"user_id"] = @(000000000);
                [questionInfo setObject:[ownerInfo objectForKey:@"display_name"] forKey:@"username"];
                [questionInfo setObject:[UIImage imageNamed:@"Icon@2x.png"] forKey:@"avatar"];
                [questionInfo setObject:@(0) forKey:@"reputation"];
                
                [questionInfo setObject:[items objectForKey:@"is_answered"] forKey:@"answered"];
                [questionInfo setObject:[items objectForKey:@"view_count"] forKey:@"views"];
                [questionInfo setObject:[items objectForKey:@"score"] forKey:@"votes"];
                [questionInfo setObject:[items objectForKey:@"body_markdown"] forKey:@"body"];
                [questionInfo setObject:[items objectForKey:@"title"] forKey:@"title"];
                [questionInfo setObject:[items objectForKey:@"question_id"] forKey:@"question_id"];
                self.questionInfoDictionary = [NSDictionary dictionaryWithDictionary:questionInfo];
            }
            else
            {
                questionInfo[@"user_id"] = ownerInfo[@"user_id"];
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
            }

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelected:) name:@"UserClicked" object:nil];
}

- (void)userSelected:(NSNotification *)notif
{
    NSString *userID = notif.object;
    ACSummaryViewController *summaryViewController = [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [summaryViewController displayUser:userID site:self.siteAPIName];
    [summaryViewController slideMenu:nil];
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
    return (indexPath.section) ? 309 : 375;//375;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == QUESTION_SECTION)
        return (self.questionInfoDictionary) ? 1 : 0;
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
        cell.userAvatarImageView.userID = self.questionInfoDictionary[@"user_id"];
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
        cell.questionMarkdownView.attributedText = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        
        cell.delegate = self;
        return cell;
    }
    static NSString *answerCellID = @"AnswerCell";
    
    NSDictionary *answerDictionary = self.answerArray[indexPath.row];
    ACAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:answerCellID forIndexPath:indexPath];
    if (!cell)
        cell = [[ACAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:answerCellID];
    cell.usernameLabel.text = [answerDictionary[@"owner"] objectForKey:@"display_name"];
    cell.userAvatarImageView.image = answerDictionary[@"avatar"];
    cell.userAvatarImageView.userID = answerDictionary[@"owner"][@"user_id"];
    cell.userReputationLabel.text = [answerDictionary[@"owner"][@"reputation"] stringValue];
    cell.voteCountLabel.text = [answerDictionary[@"score"] stringValue];
    cell.postIDLabel.text = [answerDictionary[@"answer_id"] stringValue];
    if ([answerDictionary[@"is_accepted"] boolValue])
        cell.voteCountLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
    else
        cell.voteCountLabel.textColor = [UIColor blackColor];
    
    NSString *markdownText = answerDictionary[@"body_markdown"];
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdownText error:nil];
    cell.bodyMarkdownView.attributedText = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];

    cell.delegate = self;
    return cell;
}

#pragma mark - ACQuestionDetailCellDelegate

- (BOOL)vote:(NSString *)postID postType:(NSString *)postType voteType:(NSString *)vote
{
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/%@/%@/%@",postType, postID, vote];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    
    NSString *body = [NSString stringWithFormat:@"access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&site=%@", accessToken, self.siteAPIName];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    BOOL success = YES;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataString rangeOfString:@"error"].location != NSNotFound)
        success = NO;
    
    return success;
}

- (BOOL)userDidDownvoteAnswer:(NSString *)answer
{
    return [self vote:answer postType:@"answers" voteType:@"downvote"];
}

- (BOOL)userDidDownvoteQuestion:(NSString *)question
{
    return [self vote:question postType:@"questions" voteType:@"downvote"];
}

- (BOOL)userDidUpvoteAnswer:(NSString *)answer
{
    return [self vote:answer postType:@"answers" voteType:@"upvote"];
}

- (BOOL)userDidUpvoteQuestion:(NSString *)question
{
    return [self vote:question postType:@"questions" voteType:@"upvote"];
}

@end
