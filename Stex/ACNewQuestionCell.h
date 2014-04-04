//
//  ACNewQuestionCell.h
//  Stex
//
//  Created by Chris on 4/3/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACNewQuestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *questionTitleField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

- (IBAction)dismissKeyboard:(id)sender;

@end
