//
//  HUD.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/19/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BVRackGenerator.h"
#import "BVLevelRating.h"
#import "BVLabelNode.h"

@interface BVHud : SKSpriteNode

@property (nonatomic, strong) SKSpriteNode *movesHolder;
@property (nonatomic, strong) BVLevelRating *levelRating;
@property (nonatomic, weak, nullable) BVRackGenerator *bucketRack;
@property (nonatomic, assign) BOOL enableBucketRackScrollingOnTouch;
@property (nonatomic) BOOL timerPaused; // Only set by BVLevel or BVLevelMenu
/**
 Used for level timers
 */
@property (nonatomic, assign) BOOL noTimeLeft;

+ (nonnull instancetype)topHudOfLevel:(int)levelNum wthTargets:(nonnull NSArray *)targets viewSize:(CGSize)size;
+ (nonnull instancetype)bottomHudOfLevel:(int)level withGoalOptions:(nonnull NSDictionary *)goalOptions viewSize:(CGSize)size;

- (void)updateTargetLabels:(nonnull NSArray *)targets;
- (void)updateMoves:(int)moves;
/**
 Used in global update method to update the level timer using current time.
 */
- (void)updateTimerProgress:(NSTimeInterval)currentTime;
/**
 Used to remove targets on level select button
 */
- (void)removeButtonTargets;
/**
 Use it to add time in seconds to the progress timer
 */
- (void)addTimeToTimer:(NSTimeInterval)time;
- (void)addTimeToTimer:(NSTimeInterval)time withLabelAt:(CGPoint)labelPos;

#pragma mark - Reset Methods

- (void)resetTopHud:(nonnull NSArray *)targets;
- (void)resetBottomHud:(nonnull NSDictionary *)goalOptions;
@end
