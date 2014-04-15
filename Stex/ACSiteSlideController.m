//
//  ACSiteSlideController.m
//  Stex
//
//  Created by Chris on 2/23/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSiteSlideController.h"
#import "ACAppDelegate.h"
#import "ACAlertView.h"
#import "ACNewQuestionViewController.h"
#import "ACSearchViewController.h"

#define SITE_SECTION 0
#define ACCOUNT_AREAS_SECTION 1
#define POPULAR_TAGS_SECTION 2

@implementation ACSiteSlideController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.accountAreasArray = @[@"My Questions", @"My Answers"];
        self.popularTagsArray = @[];
        self.siteOptionsArray = @{@"Registered": @"", @"All Questions" : @"", @"New Question" : @"", @"Search" : @""};
        self.username = @"";
    }
    return self;
}

- (void)setSiteAPIName:(NSString *)siteAPIName
{
    _siteAPIName = siteAPIName;
    dispatch_async(dispatch_queue_create("com.a-cstudios.site-load", NULL), ^{
        NSMutableArray *popularTagsArray = [NSMutableArray array];
        
        NSString *requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/tags?order=desc&sort=popular&site=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((", siteAPIName];
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
        NSMutableArray *items = [wrapper objectForKey:@"items"];
        for (NSDictionary *tagDictionary in items)
        {
            NSNumber *count = [tagDictionary objectForKey:@"count"];
            NSString *name = [tagDictionary objectForKey:@"name"];
            NSString *tagString = [NSString stringWithFormat:@"%@ %@", name, count];
            [popularTagsArray addObject:tagString];
        }
        self.popularTagsArray = [NSArray arrayWithArray:popularTagsArray];
        
        NSString *accessToken = [(ACAppDelegate *)[UIApplication sharedApplication].delegate accessToken];
        requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/me?order=desc&sort=reputation&site=%@&key=XB*FUGU0f4Ju9RCNhlRQ3A((&access_token=%@", siteAPIName, accessToken];
        requestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString] options:kNilOptions error:nil];
        
        if (!requestData)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                ACAlertView *alertView = [ACAlertView alertWithTitle:@"The data was nil" style:ACAlertViewStyleProgressView delegate:nil buttonTitles:@[@"Close"]];
                [alertView show];
            });
            return;
        }
        
        wrapper = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableLeaves error:nil];
        items = [wrapper objectForKey:@"items"];
        if (!items.count == 0)
        {
            NSDictionary *rootDictionary = [items objectAtIndex:0];
            if ([rootDictionary[@"user_type"] isEqualToString:@"registered"])
                self.registered = YES;
            else
                self.registered = NO;
        }
        else
            self.registered = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SITE_SECTION)
        return self.siteOptionsArray.count;
    if (section == ACCOUNT_AREAS_SECTION)
        return self.accountAreasArray.count;
    return self.popularTagsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SITE_SECTION)
        return self.siteDisplayName;
    if (section == ACCOUNT_AREAS_SECTION)
        return self.username;
    return @"Popular Tags";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SITE_SECTION)
    {
        if (indexPath.row == 0)
        {
            static NSString *registerCellID = @"RegisterCell";
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:registerCellID];
            NSString *registeredString;
            if (self.isRegistered)
                registeredString = @"Registered";
            else
                registeredString = @"Not Registered";
            cell.textLabel.text = registeredString;
            if (self.isRegistered)
            {
                cell.detailTextLabel.text = @"✓";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        static NSString *cellID = @"SiteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.text = self.siteOptionsArray.allKeys[indexPath.row];
        if ([cell.textLabel.text isEqualToString:@"New Question"])
            cell.selectionStyle = (self.isRegistered) ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleNone, cell.userInteractionEnabled = self.isRegistered;
        else
            cell.selectionStyle = UITableViewCellSelectionStyleGray, cell.userInteractionEnabled = YES;
        return cell;
    }
    
    if (indexPath.section == ACCOUNT_AREAS_SECTION)
    {
        static NSString *accountAreasCellID = @"AccountAreasCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountAreasCellID];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountAreasCellID];
        cell.textLabel.text = self.accountAreasArray[indexPath.row];
        return cell;
    }
    static NSString *popularTagsCellID = @"PopularTagsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:popularTagsCellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:popularTagsCellID];
    NSArray *components = [self.popularTagsArray[indexPath.row] componentsSeparatedByString:@" "];
    NSString *tagName = components[0];
    NSString *tagCount = components[1];
    cell.textLabel.text = tagName;
    cell.detailTextLabel.text = tagCount;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SITE_SECTION)
    {
        if (indexPath.row == 0)
        {
            if (self.registered)
                return;
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"Not Supported" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
            alertView.textView.text = @"Currently, registering for sites is not supported.";
            [alertView show];
            return;
        }
        NSString *cellTitle = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        if ([cellTitle isEqualToString:@"All Questions"])
        {
            if ([self.delegate respondsToSelector:@selector(didSelectAllQuestions)])
                [self.delegate didSelectAllQuestions];
            return;
        }
        else if ([cellTitle isEqualToString:@"New Question"])
        {
            ACNewQuestionViewController *newQuestionViewController = [[ACNewQuestionViewController alloc] initWithSite:self.siteAPIName];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newQuestionViewController];
            [self presentViewController:navigationController animated:YES completion:nil];
            return;
        }
        else if ([cellTitle isEqualToString:@"Search"])
        {
            ACSearchViewController *searchViewController = [[ACSearchViewController alloc] initWithSite:self.siteAPIName];
            [self.navigationController pushViewController:searchViewController animated:YES];
            return;
        }
    }
    
    if (indexPath.section == ACCOUNT_AREAS_SECTION)
    {
        if ([self.delegate respondsToSelector:@selector(didSelectAccountArea:)])
            [self.delegate didSelectAccountArea:self.accountAreasArray[indexPath.row]];
        return;
    }
    NSString *tag = [[self.popularTagsArray[indexPath.row] componentsSeparatedByString:@" "] objectAtIndex:0];
    if ([self.delegate respondsToSelector:@selector(didSelectTag:)])
        [self.delegate didSelectTag:tag];
}

@end
