//
//  ACNewQuestionViewController.m
//  Stex
//
//  Created by Chris on 4/3/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACNewQuestionViewController.h"
#import "ACNewQuestionCell.h"
#import "ACAppDelegate.h"
#import "Bypass.h"
#import "ACPostSender.h"

CGSize getScaledSize(CGSize original, CGFloat newWidth)
{
    CGFloat newHeight = (original.height/original.width) * newWidth;
    return CGSizeMake(newWidth, newHeight);
}

@implementation ACNewQuestionViewController
{
    UIToolbar *inputAccessoryView;
}

- (UIImage *)imageWithContentsOfURL:(NSURL *)url
{
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:imageData];
}

- (id)initWithSite:(NSString *)site
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.siteAPIName = site;
        [self.tableView registerClass:[ACNewQuestionCell class] forCellReuseIdentifier:@"NewQuestionCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ACNewQuestionCell" bundle:nil] forCellReuseIdentifier:@"NewQuestionCell"];
        inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        UIBarButtonItem *codeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"code.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertCodeBlock)];
        UIBarButtonItem *boldButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bold.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertBoldText)];
        UIBarButtonItem *italicButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"italic.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertItalicText)];
        UIBarButtonItem *linkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"link.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertLink)];
        UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"image.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertImage)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        
        [inputAccessoryView setItems:@[codeButton, boldButton, italicButton, linkButton, imageButton, flex, dismissButton]];
    }
    return self;
}

- (void)dismissKeyboard
{
    ACNewQuestionCell *cell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    [cell.bodyTextView resignFirstResponder];
}

- (void)insertImage
{
    ACNewQuestionCell *cell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *linkText = @"![enter image description here](enter image address here)";
    NSMutableString *bodyText = cell.bodyTextView.text.mutableCopy;
    [bodyText appendString:linkText];
    [cell.bodyTextView setText:bodyText];
    [cell.bodyTextView setSelectedRange:NSMakeRange(bodyText.length - 25, 24)];
}

- (void)insertLink
{
    ACNewQuestionCell *cell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *linkText = @"[enter link description here](enter link address here)";
    NSMutableString *bodyText = cell.bodyTextView.text.mutableCopy;
    [bodyText appendString:linkText];
    [cell.bodyTextView setText:bodyText];
    [cell.bodyTextView setSelectedRange:NSMakeRange(bodyText.length - 24, 23)];
}

- (void)insertItalicText
{
    ACNewQuestionCell *cell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *italicText = @"*italic text here*";
    NSMutableString *bodyText = cell.bodyTextView.text.mutableCopy;
    [bodyText appendString:italicText];
    [cell.bodyTextView setText:bodyText];
    [cell.bodyTextView setSelectedRange:NSMakeRange(bodyText.length - 17, 16)];
}

- (void)insertBoldText
{
    ACNewQuestionCell *cell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *boldText = @"**bold text here**";
    NSMutableString *bodyText = cell.bodyTextView.text.mutableCopy;
    [bodyText appendString:boldText];
    [cell.bodyTextView setText:bodyText];
    [cell.bodyTextView setSelectedRange:NSMakeRange(bodyText.length - 16, 14)];
}

- (void)insertCodeBlock
{
    ACNewQuestionCell *cell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *codeBlock = @"\r\n\r\n    ";
    NSMutableString *bodyText = cell.bodyTextView.text.mutableCopy;
    [bodyText appendString:codeBlock];
    [cell.bodyTextView setText:bodyText];
    [cell.bodyTextView setSelectedRange:NSMakeRange(bodyText.length, 0)];
}

- (void)submitQuestion
{
    ACNewQuestionCell *questionCell = (ACNewQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *tagsCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    ACTagView *tagView = (ACTagView *)[tagsCell.contentView viewWithTag:1];
    
    if (![ACPostSender postQuestionWithTitle:questionCell.questionTitleField.text body:questionCell.bodyTextView.text tags:tagView.tagsArray site:self.siteAPIName])
        return;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.tintColor = [UIColor whiteColor];
    [[UIView appearance] setTintColor:[UIColor whiteColor]];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismiss
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.tintColor = [UIColor whiteColor];
    [[UIView appearance] setTintColor:[UIColor whiteColor]];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIView appearance] setTintColor:[UIColor blueColor]];
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(submitQuestion)];
    UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = submit;
    self.navigationItem.leftBarButtonItem = dismiss;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIBarButtonItem appearance] setTintColor:[UIColor blueColor]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
        return 294.0;
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return 1;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell *preview = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        preview.textLabel.text = @"Preview";
        
        return preview;
    }
    if (indexPath.row == 1)
    {
        static NSString *cellID = @"TagCell";
        UITableViewCell *tagCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        ACTagView *tagView = [[ACTagView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        tagView.tag = 1;
        
        tagView.delegate = self;
        tagView.tagsArray = @[@"Click here to add a new tag"];
        [tagCell.contentView addSubview:tagView];
        return tagCell;
    }

    static NSString *CellIdentifier = @"NewQuestionCell";
    ACNewQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.bodyTextView.inputAccessoryView = inputAccessoryView;
    
    return cell;
}

- (void)tagWasSelected:(NSString *)tag
{
    UITableViewCell *tagCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    for (ACTagView *tagView in tagCell.contentView.subviews)
    {
        if ([tagView isKindOfClass:[ACTagView class]])
        {
            NSMutableArray *temporaryArray = tagView.tagsArray.mutableCopy;
            [temporaryArray removeObject:tag];
            tagView.tagsArray = [NSArray arrayWithArray:temporaryArray];
        }
    }
}

- (void)viewWasSelected
{
    ACAlertView *alertView = [ACAlertView alertWithTitle:@"New Tag" style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Add"]];
    [alertView show];
}

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    NSString *newTag = alertView.textField.text;
    if ([newTag isEqualToString:@""])
    {
        [alertView dismiss];
        return;
    }
    
    UITableViewCell *tagCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    for (ACTagView *tagView in tagCell.contentView.subviews)
    {
        if ([tagView isKindOfClass:[ACTagView class]])
        {
            NSMutableArray *temporaryArray = tagView.tagsArray.mutableCopy;
            for (NSString *tag in tagView.tagsArray)
            {
                if ([tag isEqualToString:newTag])
                {
                    [alertView dismiss];
                    return;
                }
                if ([tag isEqualToString:@"Click here to add a new tag"])
                    [temporaryArray removeObject:tag];
            }
            if (temporaryArray.count < 5)
                [temporaryArray addObject:newTag];
            tagView.tagsArray = [NSArray arrayWithArray:temporaryArray];
        }
    }
    [alertView dismiss];
}

- (UIImage *)scaleToSize:(CGSize)newSize image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACNewQuestionCell *newQuestionCell = (ACNewQuestionCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (indexPath.section == 1)
    {
        UIViewController *previewViewController = [[UIViewController alloc] init];
        UITextView *textView = [[UITextView alloc] initWithFrame:previewViewController.view.bounds];
        textView.editable = NO;
        
        BPParser *parser = [[BPParser alloc] init];
        BPDocument *document = [parser parse:newQuestionCell.bodyTextView.text];
        BPAttributedStringConverter *converter = [[BPAttributedStringConverter alloc] init];
        textView.attributedText = [converter convertDocument:document];
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\!\\[.*\\]\\(.*\\)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:textView.attributedText.string options:kNilOptions range:NSMakeRange(0, textView.attributedText.length)];
        for (NSTextCheckingResult *result in matches)
        {
            NSString *imageURLString;
            
            regex = [[NSRegularExpression alloc] initWithPattern:@"\\(.*\\)" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *URLMatches = [regex matchesInString:textView.attributedText.string options:kNilOptions range:result.range];
            for (NSTextCheckingResult *URLResult in URLMatches)
            {
                NSMutableString *mutableURLString = [textView.attributedText.string substringWithRange:URLResult.range].mutableCopy;
                [mutableURLString deleteCharactersInRange:NSMakeRange(0, 1)];
                [mutableURLString deleteCharactersInRange:NSMakeRange(mutableURLString.length - 1, 1)];
                
                imageURLString = mutableURLString;
            }
            
            NSMutableAttributedString *text = textView.attributedText.mutableCopy;
            
            NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
            
            UIImage *unscaledImage = [self imageWithContentsOfURL:[NSURL URLWithString:imageURLString]];
            CGFloat width = [UIScreen mainScreen].bounds.size.width - 10;
            UIImage *scaledImage = [self scaleToSize:getScaledSize(unscaledImage.size, width) image:unscaledImage];
            
            imageAttachment.image = scaledImage;
            NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
            
            [text replaceCharactersInRange:result.range withAttributedString:imageString];
            [textView setAttributedText:text];
        }
        
        [previewViewController.view addSubview:textView];
        [self.navigationController pushViewController:previewViewController animated:YES];
        
        return;
    }
    if (indexPath.row == 1)
    {
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
