//
//  ACInboxCell.h
//  Stex
//
//  Created by Chris on 2/24/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;

@interface ACInboxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *siteImageView;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@end
