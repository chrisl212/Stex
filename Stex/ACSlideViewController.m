//
//  ACSlideViewController.m
//  Stex
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSlideViewController.h"

#define USER_INFO_SECTION 0
#define SITES_SECTION 1

@implementation ACSlideViewController

- (id)init
{
    if (self= [super initWithStyle:UITableViewStyleGrouped])
    {
        self.userInfoCellTitles = @[@"Summary", @"Inbox", @"Notifications"];
        self.sitesArray = @[];
        self.siteAPIParameters = @[];
        self.iconsArray = @[];
        
        dispatch_async(dispatch_queue_create("com.a-cstudios.infoloader", NULL), ^{
            NSMutableArray *sitesArray = [NSMutableArray array];
            NSMutableArray *iconsArray = [NSMutableArray array];
            NSMutableArray *siteAPIParams = [NSMutableArray array];
            NSArray *allSites;
            
            NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *cachedSitesPath = [cachesDirectory stringByAppendingPathComponent:@"sites_cache.json"];
            /* Check if cache exists, and if it does not, fetch the list of sites */
            if (![[NSFileManager defaultManager] fileExistsAtPath:cachedSitesPath])
            {
                NSString *requestURLString = @"https://api.stackexchange.com/2.2/sites";
                NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
                [[NSFileManager defaultManager] createFileAtPath:cachedSitesPath contents:responseData attributes:nil];
                NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                allSites = [rootDictionary objectForKey:@"items"];
            }
            /* The cache does exist, so fetch the data from the cache */
            else
            {
                NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:cachedSitesPath]];
                NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableLeaves error:nil];
                allSites = [rootDictionary objectForKey:@"items"];
            }
            
            
            /* Go through sites array and get information for each site */
            for (NSDictionary *site in allSites)
            {
                NSString *siteName = [site objectForKey:@"name"];
                NSString *iconURLString = [site objectForKey:@"icon_url"];
                NSString *APIParameter = [site objectForKey:@"api_site_parameter"];
                
                NSString *iconCachePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_icon.png", APIParameter]];
                
                NSData *iconData;
                if (![[NSFileManager defaultManager] fileExistsAtPath:iconCachePath])
                {
                    iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconURLString]];
                    [[NSFileManager defaultManager] createFileAtPath:iconCachePath contents:iconData attributes:nil];
                }
                else
                    iconData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:iconCachePath]];
                UIImage *iconImage = [UIImage imageWithData:iconData];
                
                [sitesArray addObject:siteName];
                [iconsArray addObject:iconImage];
                [siteAPIParams addObject:APIParameter];
            }
            self.sitesArray = [NSArray arrayWithArray:sitesArray];
            self.iconsArray = [NSArray arrayWithArray:iconsArray];
            self.siteAPIParameters = [NSArray arrayWithArray:siteAPIParams];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    return self;
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

#pragma mark - UITableView Delegate/Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == USER_INFO_SECTION)
        return @"Account";
    return @"Sites";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == USER_INFO_SECTION)
        return self.userInfoCellTitles.count;
    return self.sitesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == USER_INFO_SECTION)
    {
        static NSString *userInfoCellID = @"UserInfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userInfoCellID];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoCellID];
        cell.textLabel.text = self.userInfoCellTitles[indexPath.row];
        return cell;
    }
    static NSString *siteCellID = @"SiteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:siteCellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:siteCellID];
    cell.textLabel.text = self.sitesArray[indexPath.row];
    cell.imageView.image = self.iconsArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == USER_INFO_SECTION)
    {
        if ([self.delegate respondsToSelector:@selector(userInfoCellWasSelected:)])
            [self.delegate userInfoCellWasSelected:self.userInfoCellTitles[indexPath.row]];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(siteWasSelected:)])
        [self.delegate siteWasSelected:self.siteAPIParameters[indexPath.row]];
}

@end
