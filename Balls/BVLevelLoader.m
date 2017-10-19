//
//  LevelLoader.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVLevelLoader.h"
#import "BVLevel.h"
#import "BitMasks.h"
#import "BVBucket.h"
#import "BVBall.h"
#import "BVSize.h"
#import "BVParticle.h"
#import "BVFlyingObject.h"
#import "BVColor.h"
#import "BVSounds.h"

@interface BVLevelLoader () <SKPhysicsContactDelegate>

@end

static const CGFloat kMinFPS = 10.0 / 60.0;

@implementation BVLevelLoader
{
    BVLevel *_level;
    BVLevel *_dummyLevel;
    BVLabelNode *_loadingLabel;
    BOOL _showLevelGoalIntroducer;
    BOOL _presentingFromHomePage;
}

- (instancetype)initWithLevel:(int)levelNum size:(CGSize)size showGoalIntroducer:(BOOL)showGoalIntroducer presentingFromHomePage:(BOOL)presentingFromHomePage
{
    self = [super init];
    
    if (self) {
        // 1. Find out recent played level number and it's group
        // 2. check if it's completed
        // 2.1 if so then increment level number by 1 in same group
        // 2.1.1 if level doesn't exist then increment group number by 1 and load it's level #1
        
        self.size = size;
        self.scaleMode = SKSceneScaleModeResizeFill;
        self.backgroundColor = [BVColor r:137 g:226 b:255];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, [BVSize valueOniPhones:-11.0 andiPads:-18.0]);
        
        _levelNum = levelNum;
        _showLevelGoalIntroducer = showGoalIntroducer;
        _presentingFromHomePage = presentingFromHomePage;
    }
    
    return self;
}

- (void)didMoveToView:(nonnull SKView *)view
{
    //self.userInteractionEnabled = YES;
    [BVParticle LoadParticleEffectFiles];
    
    BVLevel *level = [[BVLevel alloc] initWithLevel:_levelNum showGoalIntroducer:_showLevelGoalIntroducer presentingFromHomePage:_presentingFromHomePage];
    level.levelLoader = self;
    [self levelLoaded:level];
    // create a ball destroyer node which detects balls and remove them.
    SKSpriteNode *ballDestroyer = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width * 2, 1)];
    // posY = - ((half of view height) + padding);
    ballDestroyer.position = CGPointMake(0, -((CGRectGetHeight(self.view.frame) / 2) + 100));
    ballDestroyer.name = @"ballDestroyer";
    ballDestroyer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ballDestroyer.size];
    ballDestroyer.physicsBody.dynamic = NO; // make it static body
    ballDestroyer.physicsBody.categoryBitMask = PhysicsCategoryBallDestroyer;
    [self addChild:ballDestroyer];
    
    // when ball gets tapped, we move it to invisibleHandler node but keep it's original position in view. This fixes the issue where user can change ball's direction by scrolling the rack when it's in air.
    SKNode *invisibleBallHandler = [SKNode node];
    invisibleBallHandler.name = @"invisibleBallHandler";
    [self addChild:invisibleBallHandler];
}

- (void)preloadLevel:(int)levelNum
{
//    _dummyLevel = [[BVLevel alloc] initWithLevel:levelNum ofGroup:groupNum];
//    _dummyLevel.levelLoader = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _dummyLevel = [[BVLevel alloc] initWithLevel:levelNum showGoalIntroducer:_showLevelGoalIntroducer presentingFromHomePage:NO];
        _dummyLevel.levelLoader = self;
        //_dummyLevel.alpha = 0.0;
    });
}

- (void)presentPreloadedLevel
{
    [_level runAction:[SKAction fadeOutWithDuration:0.2]];
    [_level removeFromParent];
    _level = nil;
    
    if (_dummyLevel) {
        [self levelLoaded:_dummyLevel];
    }
    _dummyLevel = nil;
    //[_level runAction:[SKAction fadeInWithDuration:0.2]];
    [self preloadLevel:_levelNum];
}

- (void)levelLoaded:(BVLevel *)level
{
    if (level) {
        //[_loadingLabel removeFromParent];
        
        _level = level;
        _level.position = CGPointZero;
        _level.size = self.size;
        
        [self addChild:_level];
    }
}

#pragma mark - Helper Methods

//- (void)loadLevel:(int)levelId ofGroup:(int)groupId
//{
//    _level = [[BVLevel alloc] initWithLevel:levelId ofGroup:groupId];
//    _level.position = CGPointZero;
//    _level.size = self.size;
//    
//    [BVSize outputSize:self.size msg:@"BVLevelLoader skView"];
//    
//    [self addChild:_level];
//}

#pragma mark - Contact Detection

- (void)didBeginContact:(nonnull SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

    
    BVBall *ball = (BVBall *)firstBody.node;
    BVBucket *bucket = (BVBucket *)secondBody.node.parent;
    
    if ((secondBody.categoryBitMask & PhysicsCategoryBallCollisionEnabler) != 0) {
//        NSLog(@"PhysicsCategoryBallCollisionEnabler Hit Detected!");
        [ball enableCollisionWithOtherBalls];
    }
    else if ((secondBody.categoryBitMask & PhysicsCategoryFlyingObject) != 0) {
        BVFlyingObject *obj = (BVFlyingObject *)secondBody.node;
        [_level.flyingObjectsCanvas objectGotHit:obj byBall:ball];
    }
    else if ((secondBody.categoryBitMask & PhysicsCategoryBucketLaser) != 0) {
//        NSLog(@"Laser Hit By The Ball!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        
//        SKSpriteNode *laser = (SKSpriteNode *)secondBody.node;
        
        if (bucket.laserActive) {
            // play laser sound
            [self runAction:[BVSounds bucketLaser]];
            
            // add smoke when ball hit the laser and then remove the ball from the parent.
            SKEmitterNode *ballSmoke = [BVParticle loadFile:@"BallSmoke"];
            ballSmoke.particleColor = ball.color;
            ballSmoke.particleColorBlendFactor = 1.0;
            ballSmoke.particleColorSequence = nil;
            ballSmoke.position = CGPointMake(ball.position.x, ball.position.y - (ball.size.height / 4));
            [self addChild:ballSmoke];
            
            // laser works as ball destroyer
            [_level ballHitDestroyer:ball];
        }
    }
    else if ((secondBody.categoryBitMask & PhysicsCategoryBucketCap) != 0) {
        
        CGPoint explosionPos = CGPointMake(ball.position.x, ball.position.y - (ball.size.height / 4));
        
        // explode all colored balls when they hit the bucket cap.
        if (ball.type == BVBallTypeColored) {
            // add ball explosion
            [_level explodeBall:ball at:explosionPos];
        }
        else if (ball.type == BVBallTypeBomb) {
            // give cap destruction points
            [_level hudAddPoints:BVLevelRatingPointsTypeCapExploded withLabelOverBucket:bucket];
            
            [bucket removeBucketCap];
            [_level explodeCapAt:explosionPos withBall:ball];
        }
        
    }
    else if ((secondBody.categoryBitMask & PhysicsCategoryBallDestroyer) != 0)
    {
//        NSLog(@"ball destroyer got hit");
        [_level ballHitDestroyer:ball];
    }
    else if ((secondBody.categoryBitMask & PhysicsCategoryBucketSensor) != 0) {
        
//        NSLog(@"Sensor got hit");
        [_level sensorOfBucket:bucket gotHitByBall:ball];
        
        // temporary test
        //[_level.hudBottom addTimerProgressTime:10];
    }
}

#pragma mark - Update Loop
- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    static NSTimeInterval lastCallTime;
    NSTimeInterval timeElapsed = currentTime - lastCallTime;
    if (timeElapsed > kMinFPS) {
        timeElapsed = kMinFPS;
    }
    lastCallTime = currentTime;
    
    if (_level) {
        
        // roll clouds
        [_level.rollingThings rollBigClouds:timeElapsed];
        [_level.rollingThings rollSmallClouds:timeElapsed];

        // end the level when user have ran out of time.
        if (_level.hudBottom.noTimeLeft) {
            [_level endGameWithReason:@"Time's Up Friend!" lostConfirmed:YES];
        }
        else {
            [_level.hudBottom updateTimerProgress:currentTime];
        }
        
        if (_level.flyingObjectsCanvas) {
            [_level.flyingObjectsCanvas rollRows:timeElapsed];
        }
    }
}

@end
