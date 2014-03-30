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
    if (self= [super init])
    {
        self.userInfoCellTitles = @[@"Summary", @"Inbox", @"Notifications", @"Settings"];
        self.sitesArray = @[];
        self.siteAPIParameters = @[];
        self.iconsArray = @[];
        [self loadSites];
    }
    return self;
}

- (void)loadSites
{
    
    dispatch_async(dispatch_queue_create("com.a-cstudios.infoloader", NULL), ^{
        NSMutableArray *sitesArray = [NSMutableArray array];
        NSMutableArray *iconsArray = [NSMutableArray array];
        NSMutableArray *siteAPIParams = [NSMutableArray array];
        NSMutableArray *allSites;
        
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cachedSitesPath = [cachesDirectory stringByAppendingPathComponent:@"sites_cache.json"];
        /* Check if cache exists, and if it does not, fetch the list of sites */
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachedSitesPath])
        {
            NSString *requestURLString = @"https://api.stackexchange.com/2.2/sites?key=XB*FUGU0f4Ju9RCNhlRQ3A((";
            NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
            NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
            allSites = [[rootDictionary objectForKey:@"items"] mutableCopy];
            int current_page = 2;
            BOOL more_sites = [[rootDictionary objectForKey:@"has_more"] boolValue];
            while (more_sites)
            {
                requestURLString = [NSString stringWithFormat:@"https://api.stackexchange.com/2.2/sites?page=%d&key=XB*FUGU0f4Ju9RCNhlRQ3A((", current_page];
                responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
                rootDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                more_sites = [[rootDictionary objectForKey:@"has_more"] boolValue];
                [allSites addObjectsFromArray:[rootDictionary objectForKey:@"items"]];
                current_page++;
            }
            
            [[NSFileManager defaultManager] createFileAtPath:cachedSitesPath contents:nil attributes:nil];
            [allSites writeToFile:cachedSitesPath atomically:YES];
        }
        /* The cache does exist, so fetch the data from the cache */
        else
        {
            allSites = [NSMutableArray arrayWithContentsOfURL:[NSURL fileURLWithPath:cachedSitesPath]];
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
        self.allSites = allSites;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate = self;
    [searchBar setShowsCancelButton:YES];
    self.tableView.tableHeaderView = searchBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *sitesArray = [NSMutableArray array];
    NSMutableArray *iconsArray = [NSMutableArray array];
    NSMutableArray *siteAPIParams = [NSMutableArray array];
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *cachedSitesPath = [cachesDirectory stringByAppendingPathComponent:@"sites_cache.json"];
    NSMutableArray *allSites = [NSMutableArray arrayWithContentsOfURL:[NSURL fileURLWithPath:cachedSitesPath]];
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
    
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *tempIconArray = [NSMutableArray array];
    NSMutableArray *tempAPINames = [NSMutableArray array];
    
    for (NSString *siteName in self.sitesArray)
    {
        if ([siteName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            [tempArray addObject:siteName], [tempIconArray addObject:self.iconsArray[[self.sitesArray indexOfObject:siteName]]], [tempAPINames addObject:self.siteAPIParameters[[self.sitesArray indexOfObject:siteName]]];
    }
    self.sitesArray = [NSArray arrayWithArray:tempArray];
    self.iconsArray = [NSArray arrayWithArray:tempIconArray];
    self.siteAPIParameters = [NSArray arrayWithArray:tempAPINames];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
    NSMutableArray *sitesArray = [NSMutableArray array];
    NSMutableArray *iconsArray = [NSMutableArray array];
    NSMutableArray *siteAPIParams = [NSMutableArray array];
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *cachedSitesPath = [cachesDirectory stringByAppendingPathComponent:@"sites_cache.json"];
    NSMutableArray *allSites = [NSMutableArray arrayWithContentsOfURL:[NSURL fileURLWithPath:cachedSitesPath]];
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
    [self.tableView reloadData];
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
        [self loadSites];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(siteWasSelected:)])
        [self.delegate siteWasSelected:self.siteAPIParameters[indexPath.row]];
    [self loadSites];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SITES_SECTION)
        return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *cachedSitesPath = [cachesDirectory stringByAppendingPathComponent:@"sites_cache.json"];
    NSMutableArray *temp = [self.sitesArray mutableCopy];
    NSMutableArray *tempAPI = [self.siteAPIParameters mutableCopy];
    NSMutableArray *tempIcons = [self.iconsArray mutableCopy];
    id object = [temp objectAtIndex:sourceIndexPath.row];
    [temp removeObjectAtIndex:sourceIndexPath.row];
    [temp insertObject:object atIndex:destinationIndexPath.row];
    
    object = [tempAPI objectAtIndex:sourceIndexPath.row];
    [tempAPI removeObjectAtIndex:sourceIndexPath.row];
    [tempAPI insertObject:object atIndex:destinationIndexPath.row];
    
    object = tempIcons[sourceIndexPath.row];
    [tempIcons removeObjectAtIndex:sourceIndexPath.row];
    [tempIcons insertObject:object atIndex:destinationIndexPath.row];
    
    object = self.allSites[sourceIndexPath.row];
    [self.allSites removeObjectAtIndex:sourceIndexPath.row];
    [self.allSites insertObject:object atIndex:destinationIndexPath.row];
    
    [self.allSites writeToFile:cachedSitesPath atomically:YES];
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end
