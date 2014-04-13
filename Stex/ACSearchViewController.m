//
//  ACSearchViewController.m
//  Stex
//
//  Created by Chris on 4/13/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSearchViewController.h"
#import "ACQuestionCell.h"
#import "ACQuestionViewController.h"

#define rgb(x) x/255.0

@implementation ACSearchViewController

- (id)initWithSite:(NSString *)siteAPIName
{
    if (self = [super init])
    {
        self.siteAPIName = siteAPIName;
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView registerNib:[UINib nibWithNibName:@"ACQuestionCell" bundle:nil] forCellReuseIdentifier:@"QuestionCell"];

        self.searchItems = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
    searchBar.delegate = self;
    [searchBar setShowsScopeBar:YES];
    searchBar.scopeButtonTitles = @[@"Questions", @"Answers"];
    searchBar.barTintColor = [UIColor colorWithRed:rgb(41.0) green:rgb(75.0) blue:rgb(125.0) alpha:1.0];

    self.tableView.tableHeaderView = searchBar;
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    
    self.navigationItem.title = @"Search";
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *requestURLString = [[NSString stringWithFormat:@"https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=%@&site=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", searchBar.text, self.siteAPIName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
    NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:nil];
    self.searchItems = rootDictionary[@"items"];

    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate/DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 187.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"QuestionCell";
    
    ACQuestionCell *questionCell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    NSDictionary *questionDictionary = self.searchItems[indexPath.row];
    questionCell.voteCountLabel.text = [questionDictionary[@"score"] stringValue];
    questionCell.answerCountLabel.text = [questionDictionary[@"answer_count"] stringValue];
    questionCell.usernameLabel.text = questionDictionary[@"owner"][@"display_name"];
    
    questionCell.questionTextView.text = questionDictionary[@"title"];
    questionCell.userReputationLabel.text = [questionDictionary[@"owner"][@"reputation"] stringValue];
    questionCell.userAvatarImageView.image = [UIImage imageNamed:@"Icon.png"];
    questionCell.tagView.tagsArray = questionDictionary[@"tags"];
    
    BOOL isAnswered = [questionDictionary[@"is_answered"] boolValue];
    if (isAnswered)
        questionCell.answerCountLabel.textColor = [UIColor colorWithRed:rgb(64.0) green:rgb(128.0) blue:rgb(0.0) alpha:1.0];
    else
        questionCell.answerCountLabel.textColor = [UIColor blackColor];

    return questionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACQuestionViewController *questionViewController = [[ACQuestionViewController alloc] initWithQuestionID:[self.searchItems[indexPath.row][@"question_id"] stringValue] site:self.siteAPIName];
    [self.navigationController pushViewController:questionViewController animated:YES];
}

@end
