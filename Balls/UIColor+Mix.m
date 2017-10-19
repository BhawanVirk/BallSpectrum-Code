//
//  UIColor+Mix.m
//  Scriptive
//
//  Created by Josh Justice on 10/4/13.
//  Copyright (c) 2013 Scriptive. All rights reserved.
//

#import "UIColor+Mix.h"
#import "BVColor.h"

#define POSITION_KEY @"position"
#define COLOR_KEY @"color"

@implementation UIColor (Mix)

+(UIColor *)colorBetweenColor:(UIColor *)c1
                     andColor:(UIColor *)c2
                   percentage:(float)p
{
    // lets manually return color for some specific mixtures as automatic generation does not generate desired colors for some mixtures
    BVColor *bvColor = [[BVColor alloc] init];
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    // let's output the method and class name who is calling this method out.
    // and for the record, here are other possible things that you can access from this array
    /*
    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    */
    // uncomment below for logging out method name who have called this method.
    //NSLog(@"Method: %@ of class: %@ have called: %@", [array objectAtIndex:4], [array objectAtIndex:3], NSStringFromSelector(_cmd));
    
    if ([bvColor doTheseColors:@[c1, c2] matchWithTheseDefaultColors:@[@"blue", @"yellow"]]) {
        // blue + yellow = green, but automatic version will generate slightly grayish color because it's also mixing red in it
        return [BVColor green];
    }
    else if ([bvColor doTheseColors:@[c1, c2] matchWithTheseDefaultColors:@[@"red", @"yellow"]]) {
        // default orange is slightly different than the one we use, so we'll return our version of orange in this case.
        return [BVColor orange];
    }
    
    float p1 = 1.0 - p;
    float p2 = p;
    
    const CGFloat *components = CGColorGetComponents([c1 CGColor]);
    CGFloat r1 = components[0];
    CGFloat g1 = components[1];
    CGFloat b1 = components[2];
    CGFloat a1 = components[3];

    components = CGColorGetComponents([c2 CGColor]);
    CGFloat r2 = components[0];
    CGFloat g2 = components[1];
    CGFloat b2 = components[2];
    CGFloat a2 = components[3];

    return [UIColor colorWithRed:r1*p1 + r2*p2
                           green:g1*p1 + g2*p2
                            blue:b1*p1 + b2*p2
                           alpha:a1*p1 + a2*p2];
}

/**
 * colors - an NSArray of NSDictionaries, each with two keys:
 *   position - an NSNumber position between 0.0 and 1.0 along the gradient
 *   color - the UIColor at that position
 *
 * The elements should be in position order, least to greatest
 */
+(UIColor *)colorAlongColors:(NSArray *)colors
                  percentage:(float)p
{
    NSDictionary *entry;
    NSDictionary *nextEntry;
    NSDictionary *beforeEntry = nil;
    NSDictionary *afterEntry = nil;
    NSNumber *positionKey, *nextPositionKey;
    for( int i = 0; i < [colors count]; i++ ) {
        entry = [colors objectAtIndex:i];
        nextEntry = (i+1 < [colors count]) ? [colors objectAtIndex:i+1] : nil;
        positionKey = [entry objectForKey:POSITION_KEY];
        nextPositionKey = [nextEntry objectForKey:POSITION_KEY];
//        NSLog(@"entry %@, nextEntry %@", entry, nextEntry);
        if( p >= positionKey.floatValue
           && ( nil == nextEntry || p < nextPositionKey.floatValue ) )
        {
            beforeEntry = entry;
            afterEntry = nextEntry;
            break;
        }
    }
    // not found - less than first entry
    if( nil == beforeEntry ) {
//        NSLog(@"not found");
        afterEntry = [colors objectAtIndex:0];
    }
    
//    NSLog(@"color at %f is between %@ and %@", p, beforeEntry, afterEntry);
    
    // get color
    if( nil == beforeEntry ) {
        return [afterEntry objectForKey:COLOR_KEY];
    } else if( nil == afterEntry ) {
        return [beforeEntry objectForKey:COLOR_KEY];
    } else {
        float beforePosition = ((NSNumber *)[beforeEntry objectForKey:POSITION_KEY]).floatValue;
        float afterPosition = ((NSNumber *)[afterEntry objectForKey:POSITION_KEY]).floatValue;
        float position = (p - beforePosition) / (afterPosition - beforePosition);
        return [UIColor colorBetweenColor:[beforeEntry objectForKey:COLOR_KEY]
                                 andColor:[afterEntry objectForKey:COLOR_KEY]
                               percentage:position];
    }
}

/**
 * Takes in an array of NSNumbers and configures a color from it.
 * Position 0 is red, 1 green, 2 blue, 3 alpha.
 */
+(UIColor *)colorWithConfig:(NSArray *)config{
    return [UIColor colorWithRed:((NSNumber *)[config objectAtIndex:0]).floatValue
                           green:((NSNumber *)[config objectAtIndex:1]).floatValue
                            blue:((NSNumber *)[config objectAtIndex:2]).floatValue
                           alpha:((NSNumber *)[config objectAtIndex:3]).floatValue];
}

@end
