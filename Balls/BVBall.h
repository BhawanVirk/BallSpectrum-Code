//
//  ABBall.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 6/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BVBallType) {
    BVBallTypeColored,
    BVBallTypeBomb,
    BVBallTypeClear,
    BVBallTypeDummy
};

@interface BVBall : SKSpriteNode

@property (nonatomic, assign) BVBallType type;
@property (nonatomic, assign) BOOL inAir;
@property (nonatomic) int indexInBallsList; // only assigned by BVRackGenerator
@property (nonatomic) int countOfDestroyerHits; // used by BVLevel to call it's ballHitDestroyer method only once for single ball
/**
 We need to incorporate rack's touch functionality in this class, so need to store it in property for reference.
 */
@property (nonatomic, weak) SKNode *rack;

+ (nonnull instancetype)solidRed;
+ (nonnull instancetype)solidGreen;
+ (nonnull instancetype)solidYellow;
+ (nonnull instancetype)solidBlue;
+ (nonnull instancetype)solidOrange;
+ (nonnull instancetype)solidViolet;
+ (nonnull instancetype)clearBall;
+ (nonnull instancetype)dummyBall;
+ (nonnull instancetype)ballWithMixtureOfColor1:(nonnull UIColor *)color1 andColor2:(nonnull UIColor *)color2;
+ (nonnull instancetype)ballWithType:(BVBallType)type;
+ (nonnull instancetype)ballColored:(nonnull UIColor *)color;
- (void)enableCollisionWithOtherBalls;

@end
