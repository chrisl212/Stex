//
//  ACSettingsViewController.m
//  Stex
//
//  Created by Chris on 3/29/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACSettingsViewController.h"
#import "ACAlertView.h"
#import "ACSlideViewController.h"

@implementation ACSettingsViewController

- (id)init
{
    if (self = [super init])
    {
        [self loadOptions:NO];
    }
    return self;
}

- (void)loadOptions:(BOOL)reload
{
    self.optionsDictionary = @{@"Rearrange sites" : @"", @"Font": [[NSUserDefaults standardUserDefaults] objectForKey:@"Font"], @"Clear Cache" : @""};
    if (reload)
        [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.optionsDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    NSArray *keys = self.optionsDictionary.allKeys;
    NSArray *values = self.optionsDictionary.allValues;
    cell.textLabel.text = keys[indexPath.row];
    cell.detailTextLabel.text = values[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *key = cell.textLabel.text;
    if ([key isEqualToString:@"Font"])
    {
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.tableView.frame), self.view.frame.size.width, self.view.frame.size.height/2)];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [self.view addSubview:pickerView];
    }
    else if ([key isEqualToString:@"Clear Cache"])
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Clearing cache..." style:ACAlertViewStyleSpinner delegate:nil buttonTitles:nil];
        [alertView show];
        NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachesDir error:nil];
        for (NSString *file in fileNames)
        {
            NSString *filePath = [cachesDir stringByAppendingPathComponent:file];
            BOOL isDir;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
            if (!isDir)
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [alertView dismiss];
    }
    else if ([key isEqualToString:@"Rearrange sites"])
    {
        ACSlideViewController *slideViewController = [[ACSlideViewController alloc] init];
        self.navigationController.delegate = self;
        [self.navigationController pushViewController:slideViewController animated:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[ACSlideViewController class]])
    {
        ACSlideViewController *svc = (ACSlideViewController *)viewController;
        svc.tableView.editing = YES;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSMutableArray *fontNames = [[NSMutableArray alloc] init];
    
    NSArray *fontFamilyNames = [UIFont familyNames];
    for (NSString *familyName in fontFamilyNames)
    {
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        [fontNames addObjectsFromArray:names];
    }
    return fontNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableArray *fontNames = [[NSMutableArray alloc] init];
    
    NSArray *fontFamilyNames = [UIFont familyNames];
    for (NSString *familyName in fontFamilyNames)
    {
        
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        
        [fontNames addObjectsFromArray:names];
    }
    return [fontNames objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [[NSUserDefaults standardUserDefaults] setObject:[self pickerView:pickerView titleForRow:row forComponent:component] forKey:@"Font"];
    [self loadOptions:YES];
}

@end
