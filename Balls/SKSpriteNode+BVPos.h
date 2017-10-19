//
//  BVPos.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/15/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BVPosSide) {
    BVPosSideTop,
    BVPosSideRight,
    BVPosSideBottom,
    BVPosSideLeft
};

@interface SKSpriteNode (BVPos)

- (void)setPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin;
- (void)setPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal;
- (void)setPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal scalableMargin:(BOOL)scalableMargin;
- (CGPoint)getPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin;
- (CGPoint)getPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal;
- (CGPoint)getPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal scalableMargin:(BOOL)scalableMargin;
@end
