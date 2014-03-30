//
//  ACSiteViewController.m
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSiteViewController.h"
#import "ACAlertView.h"
#import "ACSummaryViewController.h"
#import "ACQuestionCell.h"
#import "ACQuestionViewController.h"
#import "ACAppDelegate.h"
#import "ACAnswersViewController.h"

@implementation ACSiteViewController

- (UIImage *)scaleToSize:(CGSize)newSize image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)initWithSite:(NSString *)site
{
    if (self = [super initWithNibName:NSStringFromClass([ACSiteViewController class]) bundle:nil])
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
        [alertView show];
        
        self.questionsArray = @[];
        self.siteAPIName = site;
        self.openTagName = @"All Questions";
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.siteload", NULL), ^{
            NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/info?site=%@&filter=!9WgJff6fP&key=XB*FUGU0f4Ju9RCNhlRQ3A((", site];
            
            NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *wrapperCache = [cachesDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_sitecache.json", site]];
            
            NSData *requestData;
            if (![[NSFileManager defaultManager] fileExistsAtPath:wrapperCache])
            {
                requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
                [[NSFileManager defaultManager] createFileAtPath:wrapperCache contents:requestData attributes:nil];
            }
            else
                requestData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:wrapperCache]];
            
            
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *infoDictionary = [[wrapper objectForKey:@"items"] objectAtIndex:0];
            NSDictionary *siteInfo = [infoDictionary objectForKey:@"site"];
            
            
            NSString *iconCachePath = [cachesDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_icon.png", site]];

            NSData *iconData;
            if (![[NSFileManager defaultManager] fileExistsAtPath:iconCachePath])
            {
                NSString *iconImageURLString = [siteInfo objectForKey:@"icon_url"];
                iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconImageURLString]];
                [[NSFileManager defaultManager] createFileAtPath:iconCachePath contents:iconData attributes:nil];
            }
            else
                iconData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:iconCachePath]];

            UIImage *iconImage = [self scaleToSize:CGSizeMake(30, 30) image:[UIImage imageWithData:iconData]];
            
            NSMutableArray *questionsArray = [NSMutableArray array];
            NSMutableArray *avatarURLSArray = [NSMutableArray array];
            
            NSString *questionsRequestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/questions?order=desc&sort=creation&site=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", site];
            NSData *questionData = [NSData dataWithContentsOfURL:[NSURL URLWithString:questionsRequestURLString]];
            NSDictionary *questionsWrapper = [NSJSONSerialization JSONObjectWithData:questionData options:NSJSONReadingMutableLeaves error:nil];
            NSArray *questions = [questionsWrapper objectForKey:@"items"];
            for (NSDictionary *questionDictionary in questions)
            {
                [questionsArray addObject:questionDictionary];
                if (![[[questionDictionary objectForKey:@"owner"] objectForKey:@"user_type"] isEqualToString:@"does_not_exist"])
                    [avatarURLSArray addObject:[[questionDictionary objectForKey:@"owner"] objectForKey:@"profile_image"]];
            }
            self.questionsArray = [NSArray arrayWithArray:questionsArray];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIBarButtonItem *siteSlide = [[UIBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStyleBordered target:self action:@selector(slideSiteOptions)];
                [siteSlide setTintColor:[UIColor whiteColor]];
                self.parentViewController.navigationItem.rightBarButtonItem = siteSlide;
                [self.tableView reloadData];
                [alertView dismiss];
            });
            NSMutableArray *avatarArray = [NSMutableArray array];
            for (NSString *imageURLString in avatarURLSArray)
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
                UIImage *avatar = [UIImage imageWithData:imageData];
                if (!avatar)
                    avatar = [UIImage imageNamed:@"Icon@2x.png"];
                [avatarArray addObject:avatar];
            }
            self.avatarArray = [NSArray arrayWithArray:avatarArray];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    return self;
}

- (void)slideSiteOptions
{
    ACSummaryViewController *summaryViewController = (ACSummaryViewController *)self.parentViewController;
    for (ACSiteSlideController *vc in summaryViewController.childViewControllers)
    {
        if ([vc isKindOfClass:[ACSiteSlideController class]])
        {
            vc.siteAPIName = self.siteAPIName;
            vc.delegate = self;
        }
    }
    [summaryViewController slideSiteMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideSiteOptions)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    [self.tableView registerClass:[ACQuestionCell class] forCellReuseIdentifier:@"QuestionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ACQuestionCell class]) bundle:nil] forCellReuseIdentifier:@"QuestionCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Site Slide Delegate

- (void)tagWasSelected:(NSString *)tag
{
    ACAlertView *alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
    [alertView show];
    
    self.avatarArray = nil;
    
    self.avatarArray = @[];
    dispatch_async(dispatch_queue_create("com.a-cstudios.siteload", NULL), ^{
        self.openTagName = tag;
        
        NSMutableArray *questionsArray = [NSMutableArray array];
        NSMutableArray *avatarURLSArray = [NSMutableArray array];
        NSString *questionsRequestURLString = [[NSString stringWithFormat:@"https://api.stackexchange.com/2.2/search?site=%@&order=desc&sort=creation&tagged=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", self.siteAPIName, tag] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([tag isEqualToString:@"c++"])
            questionsRequestURLString = [questionsRequestURLString stringByReplacingOccurrencesOfString:@"++" withString:@"%2b%2b"];
        
        NSData *questionData = [NSData dataWithContentsOfURL:[NSURL URLWithString:questionsRequestURLString]];
        NSDictionary *questionsWrapper = [NSJSONSerialization JSONObjectWithData:questionData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *questions = [questionsWrapper objectForKey:@"items"];
        for (NSDictionary *questionDictionary in questions)
        {
            [questionsArray addObject:questionDictionary];
            if (![[[questionDictionary objectForKey:@"owner"] objectForKey:@"user_type"] isEqualToString:@"does_not_exist"])
                [avatarURLSArray addObject:[[questionDictionary objectForKey:@"owner"] objectForKey:@"profile_image"]];
        }

        self.questionsArray = [NSArray arrayWithArray:questionsArray];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [alertView dismiss];
        });
        NSMutableArray *avatarArray = [NSMutableArray array];
        for (NSString *imageURLString in avatarURLSArray)
        {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
            UIImage *avatar = [UIImage imageWithData:imageData];
            [avatarArray addObject:avatar];
        }
        self.avatarArray = [NSArray arrayWithArray:avatarArray];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didSelectTag:(NSString *)tag
{
    for (UIViewController *vc in self.parentViewController.childViewControllers)
    {
        if ([vc isKindOfClass:[ACAnswersViewController class]])
            [vc removeFromParentViewController], [vc.view removeFromSuperview];
    }
    
    ACAlertView *alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
    [alertView show];
    
    self.avatarArray = nil;
    
    self.avatarArray = @[];
    dispatch_async(dispatch_queue_create("com.a-cstudios.siteload", NULL), ^{
        self.openTagName = tag;
        
        NSMutableArray *questionsArray = [NSMutableArray array];
        NSMutableArray *avatarURLSArray = [NSMutableArray array];
        NSString *questionsRequestURLString = [[NSString stringWithFormat:@"https://api.stackexchange.com/2.2/search?site=%@&order=desc&sort=creation&tagged=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", self.siteAPIName, tag] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([tag isEqualToString:@"c++"])
            questionsRequestURLString = [questionsRequestURLString stringByReplacingOccurrencesOfString:@"++" withString:@"%2b%2b"];
        
        NSData *questionData = [NSData dataWithContentsOfURL:[NSURL URLWithString:questionsRequestURLString]];
        NSDictionary *questionsWrapper = [NSJSONSerialization JSONObjectWithData:questionData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *questions = [questionsWrapper objectForKey:@"items"];
        for (NSDictionary *questionDictionary in questions)
        {
            [questionsArray addObject:questionDictionary];
            if (![[[questionDictionary objectForKey:@"owner"] objectForKey:@"user_type"] isEqualToString:@"does_not_exist"])
                [avatarURLSArray addObject:[[questionDictionary objectForKey:@"owner"] objectForKey:@"profile_image"]];
        }
        self.questionsArray = [NSArray arrayWithArray:questionsArray];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self slideSiteOptions];
            [alertView dismiss];
        });
        NSMutableArray *avatarArray = [NSMutableArray array];
        for (NSString *imageURLString in avatarURLSArray)
        {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
            UIImage *avatar = [UIImage imageWithData:imageData];
            [avatarArray addObject:avatar];
        }
        self.avatarArray = [NSArray arrayWithArray:avatarArray];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didSelectAccountArea:(NSString *)aa
{
    for (UIViewController *vc in self.parentViewController.childViewControllers)
    {
        if ([vc isKindOfClass:[ACAnswersViewController class]])
            [vc removeFromParentViewController], [vc.view removeFromSuperview];
    }
    
    NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
    if ([aa isEqualToString:@"My Questions"])
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Loading..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
        [alertView show];
        
        self.avatarArray = nil;
        
        self.avatarArray = @[];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.siteload", NULL), ^{
            self.openTagName = @"My Questions";
            
            NSMutableArray *questionsArray = [NSMutableArray array];
            NSMutableArray *avatarURLSArray = [NSMutableArray array];
            NSString *questionsRequestURLString = [[NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me/questions?site=%@&order=desc&sort=creation&access_token=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", self.siteAPIName, accessToken] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *questionData = [NSData dataWithContentsOfURL:[NSURL URLWithString:questionsRequestURLString]];
            NSDictionary *questionsWrapper = [NSJSONSerialization JSONObjectWithData:questionData options:NSJSONReadingMutableLeaves error:nil];
            NSArray *questions = [questionsWrapper objectForKey:@"items"];
            for (NSDictionary *questionDictionary in questions)
            {
                [questionsArray addObject:questionDictionary];
                [avatarURLSArray addObject:[[questionDictionary objectForKey:@"owner"] objectForKey:@"profile_image"]];
            }
            self.questionsArray = [NSArray arrayWithArray:questionsArray];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self slideSiteOptions];
                [alertView dismiss];
            });
            NSMutableArray *avatarArray = [NSMutableArray array];
            for (NSString *imageURLString in avatarURLSArray)
            {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
                UIImage *avatar = [UIImage imageWithData:imageData];
                [avatarArray addObject:avatar];
            }
            self.avatarArray = [NSArray arrayWithArray:avatarArray];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    if ([aa isEqualToString:@"My Answers"])
    {
        ACAnswersViewController *answersViewController = [[ACAnswersViewController alloc] init];
        ACSummaryViewController *parentViewController = (ACSummaryViewController *)self.parentViewController;
        [parentViewController addChildViewController:answersViewController];
        [parentViewController.contentView addSubview:answersViewController.view];
        [self slideSiteOptions];
    }
}

#pragma mark - Table View Delegate/Data Source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.openTagName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 187;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"QuestionCell";
    ACQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (!cell)
        cell = [[ACQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    cell.questionTextView.text = [self.questionsArray[indexPath.row] objectForKey:@"title"];
    cell.usernameLabel.text = [[self.questionsArray[indexPath.row] objectForKey:@"owner"] objectForKey:@"display_name"];
    cell.userReputationLabel.text = [[[self.questionsArray[indexPath.row] objectForKey:@"owner"] objectForKey:@"reputation"] stringValue];
    cell.tagView.tagsArray = self.questionsArray[indexPath.row][@"tags"];
    cell.tagView.delegate = self;
    if (self.avatarArray.count > 0)
    {
        cell.userAvatarImageView.image = self.avatarArray[indexPath.row];
    }
    cell.answerCountLabel.text = [[self.questionsArray[indexPath.row] objectForKey:@"answer_count"] stringValue];
    cell.voteCountLabel.text = [[self.questionsArray[indexPath.row] objectForKey:@"score"] stringValue];
    if ([self.questionsArray[indexPath.row][@"is_answered"] boolValue])
    {
        cell.answerCountLabel.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
        cell.answerCountLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.answerCountLabel.backgroundColor = [UIColor clearColor];
        cell.answerCountLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACQuestionViewController *questionViewController = [[ACQuestionViewController alloc] initWithQuestionID:self.questionsArray[indexPath.row][@"question_id"] site:self.siteAPIName];
    questionViewController.siteAPIName = self.siteAPIName;
    [self.parentViewController.navigationController pushViewController:questionViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
