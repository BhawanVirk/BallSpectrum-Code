//
//  BVFunctions.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/14/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVUtility.h"
#import "BVSize.h"
#import "BVDialogBox.h"
#import "KLCPopup.h"

@implementation BVUtility

+ (void)cleanUpChildrenAndRemove:(SKNode*)node {
    
    for (SKNode *child in node.children) {
        [BVUtility cleanUpChildrenAndRemove:child];
    }
    [node removeFromParent];
    
    //NSLog(@"everything is neat & tidy now.");
}

+ (CGSize)calculateViewArea:(UIView *)view
{
    float w = 0;
    float h = 0;
    
    for (UIView *v in [view subviews]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    
    return CGSizeMake(w, h);
}

+ (NSNumberFormatter *)currencyStyleFormatter
{
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    currencyStyle.maximumFractionDigits = 0;
    currencyStyle.currencySymbol = @" ";
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return currencyStyle;
}

#pragma mark - View Screenshot
+ (UIImage *)takeScreenshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    // old style [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Custom Alert View

// CGSizeMake(self.frame.size.width * 0.9, 150)
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message size:(CGSize)size
{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        CGSize screenSize = [BVSize originalScreenSize];
        size = [BVSize sizeOniPhones:CGSizeMake(screenSize.width * 0.9, 150) andiPads:CGSizeMake(screenSize.width * 0.7, 250)];
    }
    
    BVDialogBox *alertDialog = [[BVDialogBox alloc] initWithUi:BVDialogBoxUiRedish label:title size:size withCloseButton:YES];
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alertDialog.frame.size.width * 0.95, 0)];
    msgLabel.font = [UIFont fontWithName:@"Futura" size:[BVSize valueOniPhones:18 andiPads:20]];
    msgLabel.text = message;
    msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
    msgLabel.numberOfLines = 5;
    [msgLabel sizeToFit];
    msgLabel.center = alertDialog.center;
    msgLabel.frame = CGRectMake(msgLabel.frame.origin.x, msgLabel.frame.origin.y + 25, msgLabel.frame.size.width, msgLabel.frame.size.height);
    [alertDialog addSubview:msgLabel];
    
    KLCPopup *popup = [KLCPopup popupWithContentView:alertDialog showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToTop maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    [popup show];
}

@end
