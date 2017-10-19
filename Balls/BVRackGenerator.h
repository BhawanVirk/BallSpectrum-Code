//
//  BVRackGenerator.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/20/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BVBucket.h"
#import "BVBall.h"

@interface BVRackGenerator : SKSpriteNode

@property (nonatomic) BOOL ballsHolderGoingToAnimate;
@property (nonatomic) BOOL ballHoldersAnimating;
@property (nonatomic, assign) BOOL isScrollingPaused;
@property (nonatomic, nonnull) NSMutableArray *ballsList;
@property (nonatomic, nonnull) NSMutableArray *bucketsList;

- (nonnull instancetype)initWithBalls:(nonnull NSArray *)balls;
- (nonnull instancetype)initWithBuckets:(nonnull NSArray *)buckets bottomMargin:(float)bottomMargin;

#pragma mark - Bucket's Rack
- (CGPoint)bucketPosInRack:(nonnull BVBucket *)bucket;

#pragma mark - Ball's Rack
- (void)addBalls:(nonnull NSArray *)ballsList;
- (void)removeThisBallFromRack:(nonnull BVBall *)ball;
- (void)stopUserInteractionOnAllBalls;
- (CGPoint)ballHolderPositionOfBall:(nonnull BVBall *)ball;
- (CGPoint)ballPosInRack:(nonnull BVBall *)ball;
- (CGPoint)ballHolderPosInRack:(nonnull BVBall *)ball;
- (BOOL)zeroBallsInRack;

#pragma mark - Reset Rack
- (void)resetBallsRack:(nonnull NSArray *)balls;
- (void)resetBucketsRack:(nonnull NSArray *)buckets;
@end
