//
//  ACSiteSlideController.m
//  Stex
//
//  Created by Chris on 2/23/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSiteSlideController.h"

#define ACCOUNT_AREAS_SECTION 0
#define POPULAR_TAGS_SECTION 1

@implementation ACSiteSlideController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.accountAreasArray = @[@"My Questions", @"My Answers"];
        self.popularTagsArray = @[];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ACCOUNT_AREAS_SECTION)
        return self.accountAreasArray.count;
    return self.popularTagsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == ACCOUNT_AREAS_SECTION)
        return self.username;
    return @"Popular Tags";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
