//
//  BVButton.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 12/15/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BVButton : UIButton

@property (nonatomic, strong, nullable) NSMutableDictionary *userData;

+ (nonnull BVButton *)MoneyButtonWithVal:(nonnull NSNumber *)value fontSize:(int)fontSize size:(CGSize)buttonSize showCoin:(BOOL)showCoinImage coinSize:(CGSize)coinImgSize;
+ (nonnull BVButton *)GreenButtonWithText:(nonnull NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize;
+ (nonnull BVButton *)BluishButtonWithText:(nonnull NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize;
+ (nonnull BVButton *)RedishButtonWithText:(nonnull NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize;
+ (nonnull BVButton *)YellowishButtonWithText:(nonnull NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize;

#pragma mark - Close Buttons
+ (nonnull BVButton *)CloseButtonOfSize:(CGSize)size;
@end
