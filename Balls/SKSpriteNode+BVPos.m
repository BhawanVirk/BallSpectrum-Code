//
//  BVPos.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/15/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//
#import "SKSpriteNode+BVPos.h"
#import "BVSize.h"

@implementation SKSpriteNode (BVPos)

- (void)setPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin
{
    [self setPosRelativeTo:targetFrame side:side margin:margin setOtherValue:0];
}

- (void)setPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal
{
    [self setPosRelativeTo:targetFrame side:side margin:margin setOtherValue:otherVal scalableMargin:YES];
}

- (void)setPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal scalableMargin:(BOOL)scalableMargin
{
    self.position = [self getPosRelativeTo:targetFrame side:side margin:margin setOtherValue:otherVal scalableMargin:scalableMargin];
}

- (CGPoint)getPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin
{
    return [self getPosRelativeTo:targetFrame side:side margin:margin setOtherValue:0];
}

- (CGPoint)getPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal
{
    return [self getPosRelativeTo:targetFrame side:side margin:margin setOtherValue:0 scalableMargin:YES];
}

- (CGPoint)getPosRelativeTo:(CGRect)targetFrame side:(BVPosSide)side margin:(float)margin setOtherValue:(float)otherVal scalableMargin:(BOOL)scalableMargin
{
    float x;
    float y;
    float targetEdge;
    float currOffset;
    
    switch (side) {
        case BVPosSideTop:
            targetEdge = CGRectGetMaxY(targetFrame);
            currOffset = [self sizeBasedOnAnchorPoints].height;
            margin = (!scalableMargin) ? margin : [BVSize scalableMargin:margin type:BVSizeMarginTypeTop];
            x = 0;
            y = targetEdge + currOffset + margin;
            break;
            
        case BVPosSideBottom:
            targetEdge = CGRectGetMinY(targetFrame);
            currOffset = -[self sizeBasedOnAnchorPoints].height;
            margin = (!scalableMargin) ? -margin : [BVSize scalableMargin:-margin type:BVSizeMarginTypeBottom];
            x = 0;
            y = targetEdge + currOffset + margin;
            break;
            
        case BVPosSideLeft:
            targetEdge = CGRectGetMinX(targetFrame);
            currOffset = -[self sizeBasedOnAnchorPoints].width;
            margin = (!scalableMargin) ? -margin : [BVSize scalableMargin:-margin type:BVSizeMarginTypeLeft];
            
            x = targetEdge + currOffset + margin;
            y = 0;
            
            //            NSLog(@"LeftTargetEdge: %f", targetEdge);
            //            NSLog(@"Provided: x=%f, y=%f --- w=%f, h=%f", targetFrame.origin.x, targetFrame.origin.y, targetFrame.size.width, targetFrame.size.height);
            break;
            
        case BVPosSideRight:
            targetEdge = CGRectGetMaxX(targetFrame);
            currOffset = [self sizeBasedOnAnchorPoints].width;
            margin = (!scalableMargin) ? margin : [BVSize scalableMargin:margin type:BVSizeMarginTypeRight];
            
            x = targetEdge + currOffset + margin;
            y = 0;
            
            //            NSLog(@"RightTargetEdge: %f", targetEdge);
            //            NSLog(@"Provided: x=%f, y=%f --- w=%f, h=%f", targetFrame.origin.x, targetFrame.origin.y, targetFrame.size.width, targetFrame.size.height);
            break;
    }
    
    if (otherVal) {
        if (side == BVPosSideLeft || side == BVPosSideRight) {
            y = otherVal;
        } else {
            x = otherVal;
        }
    }
    
    return CGPointMake(x, y);
    
}

/**
 This method must not be used to get actual size of the node.
 */
- (CGSize)sizeBasedOnAnchorPoints
{
    float width = self.size.width;
    float height = self.size.height;
    
    if (self.anchorPoint.x == 0.5) {
        width = self.size.width / 2;
    }
    
    if (self.anchorPoint.y == 0.5) {
        height = self.size.height / 2;
    }
    
    return CGSizeMake(width, height);
}

@end
