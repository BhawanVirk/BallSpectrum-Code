//
//  Level.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BVHud.h"
#import "BVBucket.h"
#import "BVBall.h"
#import "BVLevelRating.h"
#import "BVFlyingObjectsCanvas.h"
#import "BVRollingThings.h"
#import "BVLevelMenu.h"

@class BVLevelLoader;

@interface BVLevel : SKSpriteNode

@property (nonatomic) BOOL interstitialAdPresented; // Only assigned by BVAds when presenting interstitial ad
@property (nonatomic, weak) BVLevelLoader *levelLoader;
@property (nonatomic, strong, nonnull) BVRollingThings *rollingThings;
@property (nonatomic, strong, nonnull) BVRackGenerator *ballsRack;
@property (nonatomic, strong, nonnull) BVRackGenerator *bucketsRack;
@property (nonatomic, strong, nonnull) BVHud *hudTop;
@property (nonatomic, strong, nonnull) BVHud *hudBottom;
@property (nonatomic, strong, nonnull) BVLevelMenu *menu;
@property (nonatomic, strong, nullable) BVFlyingObjectsCanvas *flyingObjectsCanvas;

- (nonnull instancetype)initWithLevel:(int)level showGoalIntroducer:(BOOL)showGoalIntroducer presentingFromHomePage:(BOOL)presentingFromHomePage;
- (void)sensorOfBucket:(nonnull BVBucket *)bucket gotHitByBall:(nonnull BVBall *)ball;
- (void)ballHitDestroyer:(nonnull BVBall *)ball;
- (void)hudAddPoints:(BVLevelRatingPointsType)pointsType withLabelOverBucket:(nonnull BVBucket *)bucket;
/**
 Remove All Registered Notifications.
 */
- (void)removeNotifications;
- (void)endGameWithReason:(nullable NSString *)reason;
- (void)endGameWithReason:(NSString *)reason lostConfirmed:(BOOL)lostConfirmed;

#pragma mark - General
- (void)pauseGame;
- (void)resumeGame;

#pragma mark - Tranistion Helper
- (void)goToLevelsPage;
- (void)goToHomepage;
- (void)restartLevel;

#pragma mark - External Button Handler
- (void)showGuidePageViewController;

#pragma mark - Particle Effect Methods
- (void)explodeBall:(nonnull BVBall *)ball at:(CGPoint)position;
- (void)explodeCapAt:(CGPoint)capPos withBall:(nonnull BVBall *)ball;
@end
