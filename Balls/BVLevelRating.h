//
//  BVLevelRating.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/13/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BVLevelRatingPointsType) {
    BVLevelRatingPointsTypeTargetBucket,
    BVLevelRatingPointsTypeNewBucket,
    BVLevelRatingPointsTypeCapExploded,
    BVLevelRatingPointsTypeNone
};

@interface BVLevelRating : SKSpriteNode

/**
 Total number of points earned by the user.
 */
@property (nonatomic, assign) int pointsEarned;
@property (nonatomic, assign) int numOfStarsEarned;

/**
 Get points value for given type
 */
+ (int)pointsForType:(BVLevelRatingPointsType)type;

- (instancetype)initWithStarPoints:(NSArray *)starPoints size:(CGSize)size viewSize:(CGSize)viewSize;
- (void)addPoints:(int)points;
- (void)addPointsType:(BVLevelRatingPointsType)pointsType withLabelAnimationAt:(CGPoint)labelPos;
- (void)addPoints:(int)points withLabelAnimationAt:(CGPoint)labelPos;

#pragma mark - Reset Method
- (void)resetRatings;
@end
