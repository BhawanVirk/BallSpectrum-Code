//
//  GuideContentViewController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 12/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "GuideContentViewController.h"
#import "BVLabelNode.h"
#import "BVSize.h"
#import "UIImage+Scaling.h"
#import "BVUtility.h"

@implementation GuideContentViewController

+ (NSInteger)totalPages
{
    return 5;
}

- (nonnull instancetype)initWithPageIndex:(NSUInteger)pageIndex
{
    self = [super init];
    
    if (self) {
        self.pageIndex = pageIndex;
        CGSize screenSize = [BVSize originalScreenSize];
        self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        
        UIView *contentView = [self contentViewForPageIndex:pageIndex];
        self.view = contentView;
    }
    
    return self;
}

#pragma mark - Content Helper

- (UIView *)contentViewForPageIndex:(NSUInteger)pageIndex
{
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.frame];
    
    switch (pageIndex) {
        case 0:
            [self addText:@"Slide to move balls and pipes (in some levels)" withImgNamed:@"guide-img-1" inView:contentView innerDistance:80 topMargin:50 bottomMargin:0];
            break;
            
        case 1:
            [self addText:@"Tap to drop the ball" withImgNamed:@"guide-img-2" inView:contentView innerDistance:80 topMargin:50 bottomMargin:0];
            break;
            
        case 2:
            [self addText:@"Create new colored pipes by mixing two different colors." withImgNamed:@"guide-img-3" inView:contentView innerDistance:80 topMargin:50 bottomMargin:0];
            break;
            
        case 3:
            [self addText:@"Use bomb ball to destroy pipe blocker." withImgNamed:@"guide-img-4-part-1" inView:contentView innerDistance:30 topMargin:30 bottomMargin:0];
            [self addText:@"Avoid hitting lasers." withImgNamed:@"guide-img-4-part-2" inView:contentView innerDistance:30 topMargin:50 bottomMargin:0];
            break;
            
        case 4:
            [self addText:nil withImgNamed:@"guide-img-5-part-1" inView:contentView innerDistance:20 topMargin:10 bottomMargin:0];
            [self addText:@"Creating new colored pipe" withImgNamed:@"guide-img-5-part-2" inView:contentView innerDistance:0 topMargin:20 bottomMargin:0];
            [self addText:@"Destroying pipe blocker" withImgNamed:@"guide-img-5-part-3" inView:contentView innerDistance:0 topMargin:20 bottomMargin:0];
            break;
            
        default:
            break;
    }
    
    return contentView;
}

- (void)addText:(NSString *)text withImgNamed:(NSString *)imageNamed inView:(UIView *)view innerDistance:(float)innerDistance topMargin:(float)topMargin bottomMargin:(float)bottomMargin
{
    // globalize value of margins
    innerDistance = [BVSize valueOniPhone4s:innerDistance * 0.9 iPhone5To6sPlus:innerDistance iPad:innerDistance * 1.5];
    topMargin = [BVSize valueOniPhone4s:topMargin * 0.9 iPhone5To6sPlus:topMargin iPad:topMargin * 1.5];
    bottomMargin = [BVSize valueOniPhone4s:bottomMargin * 0.9 iPhone5To6sPlus:bottomMargin iPad:bottomMargin * 1.5];
    
    UIView *lastSubview = [view.subviews lastObject];
    float viewMidX = CGRectGetMidX(view.frame);
    UIView *wrapperView = [[UIView alloc] init];
    UILabel *label = nil;
    if (text != nil) {
        float normalFontSize = [BVSize valueOniPhone4s:16 iPhone5To6sPlus:18 iPad:26];
        float labelY = (lastSubview != nil) ? CGRectGetMaxY(lastSubview.frame) : 0;
        CGSize labelSize = CGSizeMake(view.frame.size.width * 0.9, 0); // remember: sizeToFit will take care of the height
        label = [[UILabel alloc] initWithFrame:CGRectMake(viewMidX - (labelSize.width/2), labelY, labelSize.width, labelSize.height)];
        label.textColor = [UIColor blackColor];
        label.text = text;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:BVdefaultFontName() size:normalFontSize];
        [label sizeToFit];
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + topMargin, labelSize.width, label.frame.size.height);
        
        // add to view
        [wrapperView addSubview:label];
    }
    
    if (imageNamed != nil) {
        UIImage *img = [UIImage imageNamed:imageNamed];
        CGSize imgSize = [BVSize sizeOniPhone4s:CGSizeMake(img.size.width * 0.8, img.size.height * 0.8) iPhone5To6sPlus:img.size iPad:CGSizeMake(img.size.width * 1.7, img.size.height * 1.7)];
        
        float imgY = (label != nil) ? CGRectGetMaxY(label.frame) + innerDistance : (lastSubview != nil) ? CGRectGetMaxY(lastSubview.frame) + topMargin : topMargin;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.frame = CGRectMake(viewMidX - (imgSize.width/2), imgY, imgSize.width, imgSize.height);
        [wrapperView addSubview:imageView];
    }
    
    CGSize wrapperViewSize = [BVUtility calculateViewArea:wrapperView];
    wrapperView.frame = CGRectMake(0, 0, wrapperViewSize.width, wrapperViewSize.height);
    [view addSubview:wrapperView];
}

@end