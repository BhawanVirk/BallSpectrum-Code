//
//  BVResize.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/26/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVSize.h"
#import "SDiPhoneVersion.h"

@implementation BVSize

+ (CGSize)resizeUniversally:(CGSize)elemSize firstTime:(BOOL)isTheFirstTime
{
    return [BVSize resizeUniversally:elemSize firstTime:isTheFirstTime useFullWidth:NO];
}

+ (CGSize)resizeUniversally:(CGSize)elemSize firstTime:(BOOL)isTheFirstTime useFullWidth:(BOOL)useFullWidth
{
    return [BVSize resizeUniversally:elemSize firstTime:isTheFirstTime useFullWidth:useFullWidth useFullHeight:NO];
}

+ (CGSize)resizeUniversally:(CGSize)elemSize firstTime:(BOOL)isTheFirstTime useFullWidth:(BOOL)useFullWidth useFullHeight:(BOOL)useFullHeight
{
    CGSize screenSize = [BVSize screenSize];
    float screenH = screenSize.height;
    
    /*
     Note: We're testing our game on iphone 5, so we need to adjust the scale a bit on other devices to make it look EXACTLY like iphone 5's display. If we don't do scaling then we will see extra spaces on sides based on the size of the device.
     */
    
    if (isTheFirstTime) {
        
        if (screenH >= 480 && screenH < 568) {
            // iphone 4, 4s
            elemSize.width *= 0.9;
            elemSize.height *= 0.9;
        }
        else if (screenH >= 667 && screenH < 736) {
            // iphone 6
            elemSize.width *= 1.1719;
            elemSize.height *= 1.1719;
        }
        else if (screenH >= 736 && screenH < 1024) {
            // iphone 6 plus
            elemSize.width *= 1.2938;
            elemSize.height *= 1.2938;
        }
        else if (screenH >= 1024) {
            elemSize.width *= 2;
            elemSize.height *= 2;
        }
    }
    
    float finalWidth = (useFullWidth) ? [BVSize originalScreenSize].width : (elemSize.width / screenSize.width) * screenSize.width;
    float finalHeight = (useFullHeight) ? [BVSize originalScreenSize].height : (elemSize.height / screenSize.height) * screenSize.height;
    
    return CGSizeMake(finalWidth, finalHeight);
}

#pragma mark - Margin Calculations

+ (float)scalableMargin:(float)margin type:(BVSizeMarginType)type
{
    float val;
    if (type == BVSizeMarginTypeTop || type == BVSizeMarginTypeBottom) {
        val = [BVSize resizeUniversally:CGSizeMake(0, margin) firstTime:YES].height;
    }
    else if (type == BVSizeMarginTypeLeft || type == BVSizeMarginTypeRight) {
        val = [BVSize resizeUniversally:CGSizeMake(margin, 0) firstTime:YES].width;
    }
    
    return val;
}

#pragma mark - Screen Size Methods

+ (CGSize)screenSize
{
    /*
     Device Sizes With Aspect Ratio = 1.77
     iphone 4, 4s = 320x480 (New Size: 270x480)
     iphone 5, 5s = 320x568
     iphone 6     = 375x667
     iphone 6plus = 414x736
     ipad (All)   = 768x1024 (New Size: 576x1024)
     */
    CGSize currentScreenSize = [BVSize originalScreenSize];
    float screenH = currentScreenSize.height;
    
    CGSize modifiedScreenSize;
    
    if (screenH == 480) {
        // iphone 4, 4s
        modifiedScreenSize = currentScreenSize;//CGSizeMake(270, 480);
    }
    else if (screenH >= 568 && screenH < 1024) {
        // iphone 5, 5s, 6, 6 plus
        modifiedScreenSize = currentScreenSize;
    }
    else if (screenH >= 1024) {
        // All iPad's
        modifiedScreenSize = CGSizeMake(576, 1024);
    }
    
    return modifiedScreenSize;
}

+ (CGSize)originalScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (float)valueOniPhones:(float)valiPhone andiPads:(float)valiPad
{
    return [self valueOniPhone4s:valiPhone iPhone5To6sPlus:valiPhone iPad:valiPad];
}

+ (float)valueOniPhone4s:(float)val4s iPhone5To6sPlus:(float)val5To6Plus iPad:(float)valiPad
{
    float val = val5To6Plus;
    DeviceSize deviceSize = [SDiPhoneVersion deviceSize];
    
    if (deviceSize == iPhone35inch) {
        val = val4s;
    }
    else if (deviceSize == UnknowniPad) {
        val = valiPad;
    }
    
    return val;
}

+ (float)resizableValueOniPhones:(float)valiPhone andiPads:(float)valiPad
{
    float valiPhoneRes = [self resizeUniversally:CGSizeMake(valiPhone, 0) firstTime:YES].width;
    float valiPadRes = [self resizeUniversally:CGSizeMake(valiPad, 0) firstTime:YES].width;
    return [self valueOniPhone4s:valiPhone iPhone5To6sPlus:valiPhoneRes iPad:valiPadRes];
}

+ (CGSize)sizeOniPhones:(CGSize)sizeiPhone andiPads:(CGSize)sizeiPad
{
    return [self sizeOniPhone4s:sizeiPhone iPhone5To6sPlus:sizeiPhone iPad:sizeiPad];
}

+ (CGSize)sizeOniPhone4s:(CGSize)size4s iPhone5To6sPlus:(CGSize)size5To6Plus iPad:(CGSize)sizeiPad
{
    float width = [BVSize valueOniPhone4s:size4s.width iPhone5To6sPlus:size5To6Plus.width iPad:sizeiPad.width];
    float height = [BVSize valueOniPhone4s:size4s.height iPhone5To6sPlus:size5To6Plus.height iPad:sizeiPad.height];
    
    return CGSizeMake(width, height);
}

+ (CGSize)resizableSizeOniPhones:(CGSize)sizeiPhone andiPads:(CGSize)sizeiPad
{
    CGSize iPhoneResizable = [BVSize resizeUniversally:sizeiPhone firstTime:YES];
    CGSize iPadResizable = [BVSize resizeUniversally:sizeiPad firstTime:YES];
    return [self sizeOniPhones:iPhoneResizable andiPads:iPadResizable];
}

#pragma mark - Utility Methods
+ (void)outputSize:(CGSize)size msg:(NSString *)msg
{
    if (!msg) {
        msg = @"BVRESIZE";
    }
    NSLog(@"%@", [NSString stringWithFormat:@"%@.size: w=%f, h=%f", msg, size.width, size.height]);
}
@end
