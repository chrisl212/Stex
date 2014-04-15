//
//  ACQuestionViewController.m
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACQuestionViewController.h"
#import "Bypass.h"
#import "ACAppDelegate.h"
#import "ACAlertView.h"
#import "ACAnswerCell.h"
#import "ACSummaryViewController.h"
#import "ACCommentsViewController.h"
#import "NSString+HTML.h"

#define QUESTION_SECTION 0
#define ANSWER_SECTION 1

@implementation ACQuestionViewController
{
    NSString *user; //used when a user image view is clicked; see down by - userSelected:
}

- (UIImage *)imageWithContentsOfURL:(NSURL *)url
{
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    
    if (!imageData)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
            [alertView show];
        });
        return nil;
    }
    
    return [UIImage imageWithData:imageData];
}

- (id)initWithAnswerID:(NSString *)answer site:(NSString *)site
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.siteAPIName = site;
        self.answerArray = @[];
        [self.tableView registerClass:[ACQuestionDetailCell class] forCellReuseIdentifier:@"QuestionCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionDetailCell class]) bundle:nil] forCellReuseIdentifier:@"QuestionCell"];
        
        [self.tableView registerClass:[ACAnswerCell class] forCellReuseIdentifier:@"AnswerCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACAnswerCell class]) bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.answerload", NULL), ^{
            NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];

            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/answers/%@?order=desc&sort=activity&site=%@&filter=!azbR8Gjc6czKz.&key=XB*FUGU0f4Ju9RCNhlRQ3A((&access_token=%@", answer, site, accessToken];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            
            if (!requestData)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
                    [alertView show];
                });
                return;
            }
            
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
        self.siteAPIName = site;
        self.answerArray = @[];
        [self.tableView registerClass:[ACQuestionDetailCell class] forCellReuseIdentifier:@"QuestionCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionDetailCell class]) bundle:nil] forCellReuseIdentifier:@"QuestionCell"];
        
        [self.tableView registerClass:[ACAnswerCell class] forCellReuseIdentifier:@"AnswerCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACAnswerCell class]) bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.questionload", NULL), ^{
            NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
            
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%@?order=desc&sort=activity&site=%@&filter=!azbR7jYqz354wI&key=XB*FUGU0f4Ju9RCNhlRQ3A((&access_token=%@", question, site, accessToken];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            
            if (!requestData)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
                    [alertView show];
                });
                return;
            }
            
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
                
                questionInfo[@"upvoted"] = items[@"upvoted"];
                questionInfo[@"downvoted"] = items[@"downvoted"];
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
                
                questionInfo[@"upvoted"] = items[@"upvoted"];
                questionInfo[@"downvoted"] = items[@"downvoted"];
                [questionInfo setObject:[items objectForKey:@"is_answered"] forKey:@"answered"];
                [questionInfo setObject:[items objectForKey:@"view_count"] forKey:@"views"];
                [questionInfo setObject:[items objectForKey:@"score"] forKey:@"votes"];
                [questionInfo setObject:[items objectForKey:@"body_markdown"] forKey:@"body"];
                [questionInfo setObject:[items objectForKey:@"title"] forKey:@"title"];
                [questionInfo setObject:[items objectForKey:@"question_id"] forKey:@"question_id"];
                self.questionInfoDictionary = [NSDictionary dictionaryWithDictionary:questionInfo];
            }

            NSMutableArray *answerArray = [NSMutableArray array];
            NSString *answersRequestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions/%@/answers?site=%@&order=desc&sort=activity&filter=!azbR8_QNAu5IlA&key=XB*FUGU0f4Ju9RCNhlRQ3A((&access_token=%@", question, site, accessToken];
            NSData *answersRequestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:answersRequestURLString]];
            
            if (!answersRequestData)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
                    [alertView show];
                });
                return;
            }
            
            NSDictionary *answersWrapper = [NSJSONSerialization JSONObjectWithData:answersRequestData options:NSJSONReadingMutableLeaves error:nil];
            for (NSDictionary *answerDictionary in answersWrapper[@"items"])
            {
                NSMutableDictionary *modifiedDictionary = [NSMutableDictionary dictionaryWithDictionary:answerDictionary];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:answerDictionary[@"owner"][@"profile_image"]]];
                
                if (!imageData)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
                        [alertView show];
                    });
                    return;
                }
                
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
    user = userID;
    ACSummaryViewController *summaryViewController = [[ACSummaryViewController alloc] init];
    summaryViewController->isMainUser = NO;
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:summaryViewController animated:YES];
    [summaryViewController displayUser:userID site:self.siteAPIName];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[ACSummaryViewController class]])
    {
        ACSummaryViewController *summaryViewController = (ACSummaryViewController *)viewController;
        [summaryViewController displayUser:user site:self.siteAPIName];
    }
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
        cell.questionTitleLabel.text = [self.questionInfoDictionary[@"title"] stringByDecodingHTMLEntities];
        cell.usernameLabel.text = self.questionInfoDictionary[@"username"];
        cell.userAvatarImageView.image = self.questionInfoDictionary[@"avatar"];
        cell.userAvatarImageView.userID = self.questionInfoDictionary[@"user_id"];
        cell.userReputationLabel.text = [self.questionInfoDictionary[@"reputation"] stringValue];
        cell.viewsLabel.text = [NSString stringWithFormat:@"%@ views", self.questionInfoDictionary[@"views"]];
        cell.voteCountLabel.text = [self.questionInfoDictionary[@"votes"] stringValue];
        cell.postIDLabel.text = [self.questionInfoDictionary[@"question_id"] stringValue];
        
        BOOL upvoted = [self.questionInfoDictionary[@"upvoted"] boolValue];
        BOOL downvoted = [self.questionInfoDictionary[@"downvoted"] boolValue];

        if (upvoted)
            [cell.upvoteButton setSelected:YES];
        else if (downvoted)
            [cell.downvoteButton setSelected:YES];
        
        if ([self.questionInfoDictionary[@"answered"] boolValue])
            cell.voteCountLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
        else
            cell.voteCountLabel.textColor = [UIColor blackColor];
        
        NSString *htmlString = self.questionInfoDictionary[@"body"];
        htmlString = [htmlString stringByDecodingHTMLEntities];
        [cell.questionMarkdownView setMarkdown:htmlString];
        
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
    
    BOOL upvoted = [answerDictionary[@"upvoted"] boolValue];
    BOOL downvoted = [answerDictionary[@"downvoted"] boolValue];
    
    if (upvoted)
        [cell.upvoteButton setSelected:YES];
    else
        [cell.upvoteButton setSelected:NO];
    if (downvoted)
        [cell.downvoteButton setSelected:YES];
    else
        [cell.downvoteButton setSelected:NO];
    
    if ([answerDictionary[@"is_accepted"] boolValue])
        cell.voteCountLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
    else
        cell.voteCountLabel.textColor = [UIColor blackColor];
    
    NSString *markdownText = answerDictionary[@"body_markdown"];
    markdownText = [markdownText stringByDecodingHTMLEntities];
    
    BPParser *parser = [[BPParser alloc] init];
    BPDocument *document = [parser parse:markdownText];
    
    BPAttributedStringConverter *converter = [[BPAttributedStringConverter alloc] init];
    NSAttributedString *attributedText = [converter convertDocument:document];
    
    cell.bodyMarkdownView.attributedText = attributedText;

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
    
    if (!data)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
            [alertView show];
        });
        return NO;
    }
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataString rangeOfString:@"error"].location != NSNotFound)
        success = NO;
    
    return success;
}

- (BOOL)undoVote:(NSString *)postID postType:(NSString *)postType voteType:(NSString *)voteType
{
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/%@/%@/%@/undo", postType, postID, voteType];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    
    NSString *body = [NSString stringWithFormat:@"access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&site=%@", accessToken, self.siteAPIName];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    BOOL success = YES;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (!data)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
            [alertView show];
        });
        return NO;
    }
    
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

- (BOOL)userDidUndoAnswerDownvote:(NSString *)answer
{
    return [self undoVote:answer postType:@"answers" voteType:@"downvote"];
}

- (BOOL)userDidUndoAnswerUpvote:(NSString *)answer
{
    return [self undoVote:answer postType:@"answers" voteType:@"upvote"];
}

- (BOOL)userDidUndoQuestionDownvote:(NSString *)question
{
    return [self undoVote:question postType:@"questions" voteType:@"downvote"];
}

- (BOOL)userDidUndoQuestionUpvote:(NSString *)question
{
    return [self undoVote:question postType:@"questions" voteType:@"upvote"];
}

- (void)userDidSelectQuestionComments:(NSString *)question
{
    ACCommentsViewController *commentsViewController = [[ACCommentsViewController alloc] initWithPostID:question isQuestion:YES site:self.siteAPIName];
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

- (void)userDidSelectAnswerComments:(NSString *)answer
{
    ACCommentsViewController *commentsViewController = [[ACCommentsViewController alloc] initWithPostID:answer isQuestion:NO site:self.siteAPIName];
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

@end
