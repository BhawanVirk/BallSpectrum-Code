//
//  BVFlyingObjectsCreator.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BVBall.h"

typedef NS_ENUM(NSUInteger, BVFlyingObjectType) {
    BVFlyingObjectTypePoints,
    BVFlyingObjectTypePointsWithCap,
    BVFlyingObjectTypeTimer,
    BVFlyingObjectTypeTimerWithCap,
    BVFlyingObjectTypeObstacle,
    BVFlyingObjectTypeBallAdder,
    BVFlyingObjectTypeRowSpeedModifier,
    BVFlyingObjectTypeRightAngleStop,
    BVFlyingObjectTypeSurprise,
    BVFlyingObjectTypeBlank
};

typedef NS_ENUM(NSUInteger, BVFlyingObjectObstacleType) {
    BVFlyingObjectObstacleTypeSpikes
};

typedef NS_ENUM(NSUInteger, BVFlyingObjectFlyToSide) {
    BVFlyingObjectFlyToSideRight,
    BVFlyingObjectFlyToSideLeft
};

@interface BVFlyingObject : SKSpriteNode

@property (nonatomic) int givePoints; // used only with points object
@property (nonatomic) int giveTime; // used only with time object

// used only with ball giving object
@property (nonatomic) int quantityOfBallsToGive;
@property (nonatomic) BVBallType ballType;
@property (nonatomic) BVBallType givesBallOfType; // used by BVLevel's matchIsPossible method
@property (nonatomic, strong, nullable) UIColor *ballColor;

// used only with obstacle & right angle objects
@property (nonatomic) BVFlyingObjectObstacleType obstacleType;
@property (nonatomic) float blinkingInterval; // used only with Spikes object that blinks

// used only with row speed modifiers
@property (nonatomic) int increaseRowSpeedBy;
@property (nonatomic) int decreaseRowSpeedBy;

// used only with right angle stop objects
@property (nonatomic) BOOL slopeOnRightSide;

// only assigned by BVFlyingObjectsCanvas
@property (nonatomic) int rowIndex;
@property (nonatomic) int indexInActiveObjectsList;
@property (nonatomic) BOOL isBehindCurtains;
// used with backAndForth rows. Eg: flyAreaOnRight = 2 means, 2 objects to the right
@property (nonatomic) int flyAreaOnRight;
@property (nonatomic) int flyAreaOnLeft;
@property (nonatomic) int flySpeedChangeBy;
@property (nonatomic) BVFlyingObjectFlyToSide flyingToSide;
@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) BOOL originalPositionModified;

@property (nonatomic) BVFlyingObjectType type;

+ (nonnull instancetype)Points:(int)givePoints withCap:(BOOL)withCap;
+ (nonnull instancetype)Timer:(int)seconds withCap:(BOOL)withCap;
+ (nonnull instancetype)SpikesWithBlinkInterval:(float)blinkingInterval;
+ (nonnull instancetype)SpikesWithBlinkInterval:(float)blinkingInterval startRandomly:(BOOL)startRandomly;
+ (nonnull instancetype)GiveBallType:(BVBallType)ballType color:(nullable UIColor *)color quantity:(int)quantityOfBallsToGive;
+ (nonnull instancetype)RowSpeedIncreaseBy:(int)by;
+ (nonnull instancetype)RowSpeedDecreaseBy:(int)by;
+ (nonnull instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope;
+ (nonnull instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope blinkingInt:(float)blinkingInterval startRandomly:(BOOL)startRandomly;
+ (nonnull instancetype)Surprise;
+ (nonnull instancetype)Blank;

#pragma mark - backAndForth row's compatible version of initializers
+ (nonnull instancetype)Points:(int)givePoints withCap:(BOOL)withCap flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)Timer:(int)seconds withCap:(BOOL)withCap flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)SpikesWithBlinkInterval:(float)blinkingInterval flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)SpikesWithBlinkInterval:(float)blinkingInterval startRandomly:(BOOL)startRandomly flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)GiveBallType:(BVBallType)ballType color:(nullable UIColor *)color quantity:(int)quantityOfBallsToGive flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)RowSpeedIncreaseBy:(int)by flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)RowSpeedDecreaseBy:(int)by flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope blinkingInt:(float)blinkingInterval startRandomly:(BOOL)startRandomly flyOptions:(nonnull NSDictionary *)flyOptions;
+ (nonnull instancetype)SurpriseWithFlyOptions:(nonnull NSDictionary *)flyOptions;

#pragma mark - Object Transformation
- (void)transformIntoBlankObject;

#pragma mark - Object Cap Methods
- (BOOL)isCapped;
- (void)destroyCap;
@end
