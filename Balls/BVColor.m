//
//  BVColor.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/1/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVColor.h"
#import "UIColor+Mix.h"

@implementation BVColor

+ (UIColor *)red
{
    return [BVColor r:255 g:0 b:0];
}

+ (UIColor *)green
{
    return [BVColor r:0 g:167 b:76];
}

+ (UIColor *)blue
{
    return [BVColor r:0 g:71 b:255];
}

+ (UIColor *)yellow
{
    return [BVColor r:255 g:227 b:0];
}

+ (UIColor *)orange
{
    return [BVColor r:255 g:127 b:0];
}

+ (UIColor *)violet
{
    return [BVColor r:188 g:0 b:255];
}

#pragma mark - Utility Methods

- (NSDictionary *)rgbChart
{
    return @{
             @"red": @[@(255.0/255.0f), @(0.0/255.0f), @(0.0/255.0f)],
             @"green": @[@(0.0/255.0f), @(167.0/255.0f), @(76.0/255.0f)],
             @"blue": @[@(0.0/255.0f), @(71.0/255.0f), @(255.0/255.0f)],
             @"yellow": @[@(255.0/255.0f), @(227.0/255.0f), @(0.0/255.0f)],
             @"orange": @[@(255.0/255.0f), @(127.0/255.0f), @(0.0/255.0f)],
             @"violet": @[@(188.0/255.0f), @(0.0/255.0f), @(255.0/255.0f)],
             };
}

+ (UIColor *)r:(float)r g:(float)g b:(float)b
{
    return [BVColor r:r g:g b:b alpha:1.0];
}

+ (UIColor *)r:(float)r g:(float)g b:(float)b alpha:(float)alpha
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
}

- (BOOL)doTheseColors:(NSArray <UIColor *>*)given matchWithTheseDefaultColors:(NSArray <NSString *>*)defaultColors
{
    const CGFloat *givenColor1 = CGColorGetComponents([given[0] CGColor]);
    const CGFloat *givenColor2 = CGColorGetComponents([given[1] CGColor]);
    const CGFloat *swapHelper = CGColorGetComponents([[UIColor clearColor] CGColor]);
    
    NSArray *defaultColor1 = [[self rgbChart] objectForKey:defaultColors[0]];
    NSArray *defaultColor2 = [[self rgbChart] objectForKey:defaultColors[1]];
    
    int i = 0;
    int givenColorCount1 = 0;
    int givenColorCount2 = 0;
    BOOL colorsSwaped = NO;
    
    int totalCycles = 0;
    
    while (i < 3) {
        totalCycles++;
        
        if ([[NSString stringWithFormat:@"%.2f", givenColor1[i]] compare:[NSString stringWithFormat:@"%.2f", [defaultColor1[i] floatValue]]] == NSOrderedSame) {
            givenColorCount1++;
        }
        
        if ([[NSString stringWithFormat:@"%.2f", givenColor2[i]] compare:[NSString stringWithFormat:@"%.2f", [defaultColor2[i] floatValue]]] == NSOrderedSame) {
            givenColorCount2++;
        }
        
        i++;
        
        // if this is the last loop cycle and both blueCount and yellowCount are != 3 then
        // try switching their value. (it might be other way around)
        // And reset the loop to start from beginning
        if (i == 3 && givenColorCount1 != 3 && givenColorCount2 != 3 && colorsSwaped == NO) {
            
            // NSLog(@"Colors Swapped!");
            
            // swap provided colors
            swapHelper = givenColor1;
            givenColor1 = givenColor2;
            givenColor2 = swapHelper;
            
            // remeber that we've tried swapping the colors. (so that swapping should be done once only)
            colorsSwaped = YES;
            // reset the loop and colorCounts
            givenColorCount1 = 0;
            givenColorCount2 = 0;
            i = 0;
        }
    }
    
    //NSLog(@"givenColorCount1 = %i, givenColorCount2 = %i", givenColorCount1, givenColorCount2);
    
    if (givenColorCount1 == 3 && givenColorCount2 == 3) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)doTheseTwoColorsMatch:(NSArray <UIColor *>*)colors
{
    // lets save rgb values of each color in an array
    NSMutableArray *rgbArray = [NSMutableArray array];
    for (UIColor *color in colors) {
        const CGFloat *colorComponents = CGColorGetComponents([color CGColor]);
        NSNumber *rVal = [BVColor roundNumber:(float)colorComponents[0] upTo:5];
        NSNumber *gVal = [BVColor roundNumber:(float)colorComponents[1] upTo:5];
        NSNumber *bVal = [BVColor roundNumber:(float)colorComponents[2] upTo:5];
        
        // this will prevent nil object error
        rVal = (!rVal) ? [NSNumber numberWithInt:0] : rVal;
        gVal = (!gVal) ? [NSNumber numberWithInt:0] : gVal;
        bVal = (!bVal) ? [NSNumber numberWithInt:0] : bVal;
        
        [rgbArray addObject:@[rVal, gVal, bVal]];

    }
    
    if ([rgbArray[0] isEqualToArray:rgbArray[1]]) {
        return YES;
    }
    
    return NO;
}

+ (UIColor *)mixEmUp:(NSArray <UIColor *>*)colors
{
    UIColor *finalColor = [UIColor clearColor];
    
    for (int i = 0; i < colors.count; i++) {
        UIColor *color = [colors objectAtIndex:i];
        // let's just save the first color and do nothing with it at the time
        if (i == 0) {
            finalColor = color;
        }
        else {
            // this is where mixing happens as we have two colors on hand
            finalColor = [UIColor colorBetweenColor:finalColor andColor:color percentage:0.5];
        }
    }
    
    // NSLog(@"Final Color: %@", finalColor);
    
    return finalColor;
}

+ (NSNumber *)roundNumber:(float)num upTo:(NSUInteger)upTo
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.maximumFractionDigits = upTo;
    return [nf numberFromString:[NSNumber numberWithFloat:num].stringValue];
}
@end
