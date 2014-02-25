//
//  ACQuestionCell.h
//  Stex
//
//  Created by Chris on 2/23/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;
#import "ACTagView.h"

@interface ACQuestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userReputationLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet ACTagView *tagView;

@end
