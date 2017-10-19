//
//  BVColor.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/1/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This class defines default color sets used for buckets and balls
 */
@interface BVColor : UIColor

+ (UIColor *)red;
+ (UIColor *)green;
+ (UIColor *)blue;
+ (UIColor *)yellow;
+ (UIColor *)orange;
+ (UIColor *)violet;
+ (UIColor *)r:(float)r g:(float)g b:(float)b;
+ (UIColor *)r:(float)r g:(float)g b:(float)b alpha:(float)alpha;
+ (BOOL)doTheseTwoColorsMatch:(NSArray <UIColor *>*)colors;
+ (UIColor *)mixEmUp:(NSArray <UIColor *>*)colors;
- (BOOL)doTheseColors:(NSArray <UIColor *>*)given matchWithTheseDefaultColors:(NSArray <NSString *>*)defaultColors;

@end
