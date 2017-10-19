//
//  BVDialogBox.h
//  BallSpectrum
//
//  Created by Bhawan Virk on 1/17/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLCPopup.h"

typedef NS_ENUM(NSUInteger, BVDialogBoxUi) {
    BVDialogBoxUiRedish,
    BVDialogBoxUiBrown,
    BVDialogBoxUiBlack
};

@interface BVDialogBox : UIView

@property (nonatomic, readonly) float labelSize;
@property (nonatomic, readonly) UIImageView *labelBarView;
@property (nonatomic) UIColor *contentBackgroundColor;
@property (nonatomic, weak) KLCPopup *popup; // only assigned by external class, and will be used in close button's action handler method

- (instancetype)initWithUi:(BVDialogBoxUi)uiType label:(NSString *)label size:(CGSize)size withCloseButton:(BOOL)addCloseButton;

@end
