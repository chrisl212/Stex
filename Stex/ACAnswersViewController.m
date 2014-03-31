//
//  ACAnswersViewController.m
//  Stex
//
//  Created by Chris on 2/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACAnswersViewController.h"
#import "ACAppDelegate.h"
#import "Bypass.h"
#import "ACCommentsViewController.h"

@implementation ACAnswersViewController

- (id)initWithSite:(NSString *)site
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.siteAPIName = site;
        [self.tableView registerClass:[ACAnswerCell class] forCellReuseIdentifier:@"AnswerCell"];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACAnswerCell class]) bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
        
        self.answersArray = @[];
        dispatch_async(dispatch_queue_create("com.a-cstudios.answersload", NULL), ^{
            NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/answers?order=desc&sort=creation&site=%@&access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&filter=!9WgJfjxe6", site, accessToken];
            NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:nil];
            NSArray *items = wrapper[@"items"];
            NSMutableArray *answersArray = [NSMutableArray arrayWithArray:items];
            BOOL hasMore = [wrapper[@"has_more"] boolValue];
            NSInteger pageNumber = 2;
            while (hasMore)
            {
                requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/answers?page=%d&order=desc&sort=creation&site=%@&access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&filter=!9WgJfjxe6", pageNumber, site, accessToken];
                requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
                wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:nil];
                items = wrapper[@"items"];
                [answersArray addObjectsFromArray:items];
                hasMore = [wrapper[@"has_more"] boolValue];
                pageNumber++;
            }
            requestURLString = [answersArray firstObject][@"owner"][@"profile_image"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            self.avatarImage = [UIImage imageWithData:imageData];
            self.answersArray = [NSArray arrayWithArray:answersArray];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.answersArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 309;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AnswerCell";
    ACAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *answerDictionary = self.answersArray[indexPath.row];
    
    cell.upvoteButton.hidden = YES;
    cell.downvoteButton.hidden = YES;
    cell.userAvatarImageView.image = self.avatarImage;
    cell.usernameLabel.text = answerDictionary[@"owner"][@"display_name"];
    cell.postIDLabel.text = [answerDictionary[@"answer_id"] stringValue];
    
    BPParser *parser = [[BPParser alloc] init];
    BPDocument *document = [parser parse:answerDictionary[@"body_markdown"]];
    
    BPAttributedStringConverter *converter = [[BPAttributedStringConverter alloc] init];
    NSAttributedString *attributedText = [converter convertDocument:document];
    
    cell.bodyMarkdownView.attributedText = attributedText;

    cell.userReputationLabel.text = [answerDictionary[@"owner"][@"reputation"] stringValue];
    cell.voteCountLabel.text = [answerDictionary[@"score"] stringValue];
    BOOL isAccepted = [answerDictionary[@"is_accepted"] boolValue];
    cell.voteCountLabel.backgroundColor = (isAccepted) ? [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0] : [UIColor clearColor];
    cell.voteCountLabel.textColor = (isAccepted) ? [UIColor whiteColor] : [UIColor blackColor];
    cell.delegate = self;
    
    return cell;
}

- (void)userDidSelectAnswerComments:(NSString *)answer
{
    ACCommentsViewController *commentsViewController = [[ACCommentsViewController alloc] initWithPostID:answer isQuestion:NO site:self.siteAPIName];
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

@end
