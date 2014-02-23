//
//  ACSiteSlideController.h
//  Stex
//
//  Created by Chris on 2/23/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

@import UIKit;

@protocol ACSiteSlideControllerDelegate <NSObject>

@optional
- (void)didSelectTag:(NSString *)tag;
- (void)didSelectAccountArea:(NSString *)aa;

@end

@interface ACSiteSlideController : UITableViewController

@property (strong, nonatomic) NSArray *accountAreasArray;
@property (strong, nonatomic) NSArray *popularTagsArray;
@property (strong, nonatomic) NSString *siteAPIName;
@property (strong, nonatomic) NSString *username;
@property (weak, nonatomic) id<ACSiteSlideControllerDelegate> delegate;

@end
