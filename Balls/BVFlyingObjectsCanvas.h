//
//  BVFlyingObjects.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/14/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BVFlyingObject.h"
#import "BVBall.h"

@class BVLevel;

@interface BVFlyingObjectsCanvas : SKSpriteNode

@property (nonatomic, weak, nullable) BVLevel *level;
@property (nonatomic, nullable) NSMutableArray *activeBallGiverFlyingObjects;

- (nonnull instancetype)initWithObjects:(nonnull NSArray *)objects scrollingDirections:(nonnull NSArray *)rowScrollingDirections scrollingSpeeds:(nonnull NSArray *)rowScrollingSpeeds backAndForthRows:(nullable NSArray *)backAndForthRows rolling:(nonnull NSArray *)rolling switchRows:(BOOL)switchRows;
- (void)objectGotHit:(nonnull BVFlyingObject *)object byBall:(nonnull BVBall *)ball;
- (void)rollRows:(NSTimeInterval)timeElapsed;

@end
