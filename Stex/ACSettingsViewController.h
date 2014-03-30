//
//  ACSettingsViewController.h
//  Stex
//
//  Created by Chris on 3/29/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *optionsDictionary;

@end
