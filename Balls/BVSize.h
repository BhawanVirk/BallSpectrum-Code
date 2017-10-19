//
//  BVResize.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/26/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BVSizeMarginType) {
    BVSizeMarginTypeTop,
    BVSizeMarginTypeBottom,
    BVSizeMarginTypeLeft,
    BVSizeMarginTypeRight
};

/**
 This class maintains aspect ratio of 1.77 on all devices including iPhone's and iPad's.
 */
@interface BVSize : SKNode

/**
 Provide the size that you have tested on smallest screen size. This method
 works from small screen to the large.
 */
+ (CGSize)resizeUniversally:(CGSize)elemSize firstTime:(BOOL)isTheFirstTime;
+ (CGSize)resizeUniversally:(CGSize)elemSize firstTime:(BOOL)isTheFirstTime useFullWidth:(BOOL)useFullWidth;
+ (CGSize)resizeUniversally:(CGSize)elemSize firstTime:(BOOL)isTheFirstTime useFullWidth:(BOOL)useFullWidth useFullHeight:(BOOL)useFullHeight;
+ (float)scalableMargin:(float)margin type:(BVSizeMarginType)type;
+ (CGSize)screenSize;
+ (CGSize)originalScreenSize;
+ (void)outputSize:(CGSize)size msg:(nullable NSString *)msg;
/**
 Will return the given value based on current device.
 */
+ (float)valueOniPhone4s:(float)val4s iPhone5To6sPlus:(float)val5To6Plus iPad:(float)valiPad;
+ (float)valueOniPhones:(float)valiPhone andiPads:(float)valiPad;
+ (float)resizableValueOniPhones:(float)valiPhone andiPads:(float)valiPad;
+ (CGSize)sizeOniPhones:(CGSize)sizeiPhone andiPads:(CGSize)sizeiPad;
+ (CGSize)sizeOniPhone4s:(CGSize)size4s iPhone5To6sPlus:(CGSize)size5To6Plus iPad:(CGSize)sizeiPad;
+ (CGSize)resizableSizeOniPhones:(CGSize)sizeiPhone andiPads:(CGSize)sizeiPad;
@end
