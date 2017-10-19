//
//  GuideContentViewController.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 12/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideContentViewController : UIViewController

@property (nonatomic, assign) NSUInteger pageIndex;

+ (NSInteger)totalPages;
- (nonnull instancetype)initWithPageIndex:(NSUInteger)pageIndex;

@end
