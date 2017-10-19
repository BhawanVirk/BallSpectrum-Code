//
//  BVFunctions.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/14/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVUtility : NSObject

// Deep cleaning on node
+ (void)cleanUpChildrenAndRemove:(SKNode*)node;
+ (CGSize)calculateViewArea:(UIView *)view;
+ (NSNumberFormatter *)currencyStyleFormatter;
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message size:(CGSize)size;
+ (UIImage *)takeScreenshotOfView:(UIView *)view;

@end
