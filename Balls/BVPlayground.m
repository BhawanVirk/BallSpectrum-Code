//
//  BVPlayground.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/29/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVPlayground.h"
#import "BVPlaygroundHero.h"
#import "BVPlaygroundHud.h"
#import "BVPlaygroundRow.h"
#import "BVLabelNode.h"
#import "BVPlaygroundBitmasks.h"
#import "BVSize.h"
#import "BVColor.h"
#import "SKSpriteNode+BVPos.h"
#import "UIImage+Scaling.h"
#import "BVRollingThings.h"
#import "BVGameData.h"
#import "BVAds.h"
#import "BVSounds.h"

@import GoogleMobileAds;

static const CGFloat kMinFPS = 10.0 / 60.0;
static const float kGroundScrollSpeed = 300;
static NSString* const BVGameDataChecksumKey = @"BVGameDataChecksumKey";

@interface BVPlayground () <SKPhysicsContactDelegate>

@end

@implementation BVPlayground
{
    BVAds *_ads;
    BVPlaygroundHero *_hero;
    BVPlaygroundHud *_hud;
    SKSpriteNode *_tapInstructions;
    SKSpriteNode *_gameOverNode;
    NSMutableArray *_objectRows;
    BVPlaygroundRow *_lastObjectsRow;
    BVRollingThings *_rollingThings;
    BOOL _stopRolling;
    BOOL _startedByUser; // will become YES, when user tapped for first time
    BOOL _gameOver;
    float _applyHeroImpulse;
    float _heroVelocityDyLimit;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.size = [BVSize originalScreenSize];
        self.scaleMode = SKSceneScaleModeResizeFill;
        self.backgroundColor = [BVColor r:137 g:226 b:255];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.physicsWorld.contactDelegate = self;
        
        float gravityDy = [BVSize valueOniPhones:-11.0 andiPads:-15.8];
        self.physicsWorld.gravity = CGVectorMake(0, gravityDy);
        
        _startedByUser = NO;
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    _applyHeroImpulse = [BVSize valueOniPhones:40 andiPads:60];
    _heroVelocityDyLimit = [BVSize valueOniPhones:480 andiPads:750];
    
    _rollingThings = [[BVRollingThings alloc] init];
    _rollingThings.parentNode = self;
    
    // setup hud
    _hud = [[BVPlaygroundHud alloc] init];
    [_hud setPosRelativeTo:self.frame side:BVPosSideTop margin:-(_hud.size.height/2)];
    _hud.position = CGPointMake(0, (self.size.height/2) - (_hud.size.height/2));
    [self addChild:_hud];
    
    // add main hero in the middle
    [self setupHero];
    
    // add tap label besides hero
    [self setupTapLabel];
    
    // setup ground background
    [self setupGround];
    
    // setup background
    [self setupBackground];
    
    // add object rows
    [self setupObjectRows];
    
    if ([[BVGameData sharedGameData] shouldDisplayAds]) {
        // setup ads
        UIViewController *parentVc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
        _ads = [[BVAds alloc] initWithReachability:YES];
        _ads.playgroundScene = self;
        _ads.noInterstitialAdForThisManyTimes = 3;
        
        // load banner ad
        [_ads prepareBannerAdWithRootVC:parentVc];
        GADBannerView *bannerAd = _ads.bannerViewAd;
        bannerAd.center = CGPointMake(CGRectGetMidX(parentVc.view.frame), CGRectGetMaxY(parentVc.view.frame) - CGRectGetHeight(bannerAd.frame)/2);
        [parentVc.view addSubview:bannerAd];
    }
}

#pragma mark - Helpers

- (void)setupHero
{
    _hero = [[BVPlaygroundHero alloc] initWithColor:[BVColor violet]];
    _hero.position = CGPointMake(-(self.size.width / 5), 0);
    [self addChild:_hero];
}

- (void)setupBackground
{
    SKSpriteNode *skyLimit = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, 1)];
    skyLimit.position = CGPointMake(0, CGRectGetMaxY(self.frame) + (_hero.size.height));
    skyLimit.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:skyLimit.size];
    skyLimit.physicsBody.affectedByGravity = NO;
    skyLimit.physicsBody.dynamic = NO;
    skyLimit.physicsBody.categoryBitMask = BVPlaygroundPhysicsCategorySkyEnd;
    [self addChild:skyLimit];
    
    [_rollingThings addClouds];
    
    // add grass background
    SKSpriteNode *grass = [_rollingThings grass];
    grass.position = CGPointMake(0, CGRectGetMinY(self.frame) + (grass.size.height/1.5));
    grass.zPosition = 8;
    [self addChild:grass];
}

- (void)setupGround
{
    [_rollingThings addGrassyGround];
    
    SKSpriteNode *ground1 = _rollingThings.groundTextures[0];

    // Add ground surface to detect ball collisions
    SKSpriteNode *groundSurface = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, 1)];
    groundSurface.position = CGPointMake(0, CGRectGetMaxY(ground1.frame) - 1);
    groundSurface.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:groundSurface.size];
    groundSurface.physicsBody.affectedByGravity = NO;
    groundSurface.physicsBody.dynamic = NO;
    groundSurface.physicsBody.categoryBitMask = BVPlaygroundPhysicsCategoryGround;
    [self addChild:groundSurface];
}

- (void)setupObjectRows
{
    // initialize object rows array
    _objectRows = [NSMutableArray array];
    CGSize groundSize = ((SKSpriteNode *)_rollingThings.groundTextures[0]).size;
    
    CGSize rowSize = [BVSize resizeUniversally:CGSizeMake(90, 0) firstTime:YES];
    rowSize = CGSizeMake(rowSize.width, self.size.height - groundSize.height);
    
    BVPlaygroundRow *previousRow;
    for (int i = 0; i < 6; i++) {
        BVPlaygroundRow *row = [[BVPlaygroundRow alloc] initWithColor:[UIColor clearColor] size:rowSize];
        row.pos = i;
        row.groundSize = groundSize;
        
        if (!previousRow) {
            row.position = CGPointMake(CGRectGetMaxX(self.frame) + row.size.width / 2, groundSize.height/2);
        }
        else {
            [row setPosRelativeTo:previousRow.frame side:BVPosSideRight margin:0 setOtherValue:previousRow.position.y];
        }
        
        // create cells & fill them with objects
        [row createObjectCells];
        
        [self addChild:row];
        [_objectRows addObject:row];
        
        previousRow = row;
        
        // last row
        if (i == 5) {
            _lastObjectsRow = row;
        }
    }
    
    // setup .prevObjRow and fill cells
    for (BVPlaygroundRow *row in _objectRows) {
        if (row.pos == 0) {
            // check if last row got any cells
            BVPlaygroundRow *lastRow = (BVPlaygroundRow *)[_objectRows lastObject];
            if (lastRow.isEven) {
                row.prevObjRow = [_objectRows lastObject];
            } else {
                // second last row will become first row's prevObjRow
                row.prevObjRow = _objectRows[_objectRows.count - 2];
            }
        }
        else {
            if (row.isEven) {
                row.prevObjRow = _objectRows[row.pos - 2];
            }
        }
        
        [row fillCells];
    }
    
    [BVSize outputSize:self.size msg:@"self"];
}

- (void)setupTapLabel
{
    _tapInstructions = [SKSpriteNode node];
    _tapInstructions.zPosition = 10;
    
    SKSpriteNode *pointingHand = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"pointing-hand"] size:[BVSize resizeUniversally:CGSizeMake(40, 20) firstTime:YES]];
    pointingHand.position = CGPointMake(_hero.position.x + (pointingHand.size.width * 1.5), _hero.position.y);
    [_tapInstructions addChild:pointingHand];
    
    SKAction *pointingAnimation = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:10 y:0 duration:0.3],
                                                                                     [SKAction moveByX:-10 y:0 duration:0.3]]]];
    [pointingHand runAction:pointingAnimation];
    
    [self addChild:_tapInstructions];
}

- (void)gameStarted
{
    _startedByUser = YES;
    
    // enable gravitational force on hero
    _hero.physicsBody.affectedByGravity = YES;
    // remove tap label
    [_tapInstructions removeFromParent];
}

- (void)gameOver
{
    // play sound
    [self runAction:[BVSounds playgroundCollision]];
    
    _gameOver = YES;
    _stopRolling = YES;
    [_hero noMoreCollision];
    self.userInteractionEnabled = NO;
    [self saveGameData];
    
    // present game over node
    [self setupGameOverNode];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
    });
}

- (void)restartGame
{
    if ([[BVGameData sharedGameData] shouldDisplayAds]) {
        // present interstitial ad
        UIViewController *parentVc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
        [_ads presentInterstitialAdFromRootVC:parentVc];
    }
    
    // remove all object rows
    [self enumerateChildNodesWithName:@"row" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeFromParent];
    }];
    
    for (SKSpriteNode *node in _tapInstructions.children) {
        [node removeFromParent];
    }
    
    // remove hero
    [_hero removeFromParent];
    
    [self setupHero];
    
    // add tap label besides hero
    [self setupTapLabel];
    [self setupObjectRows];

    _stopRolling = NO;
    _startedByUser = NO;
    self.userInteractionEnabled = YES;
    [_hud resetScores];
    
    _gameOver = NO;
    [self removeGameOverNode];
}

- (void)saveGameData
{
    // Save total coins now. We save scores in their coresponding method which
    // first check's if the record has been broken or not, unless their is no
    // need to save the scores.
    [[BVGameData sharedGameData] saveCoins:_hud.coinsCollected];
}

#pragma mark - Game Over Node
- (void)setupGameOverNode
{
    if (!_gameOverNode.parent) {
        _gameOverNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.size];
        _gameOverNode.name = @"game-over-node";
        _gameOverNode.alpha = 0.0;
        _gameOverNode.zPosition = 11;
        
        //BVLabelNode *gameOver = [BVLabelNode labelWithText:@"Game Over!" color:[UIColor whiteColor] size:36 shadowColor:[UIColor colorWithWhite:1 alpha:0.5] offSetX:2 offSetY:-2];
        BVLabelNode *gameOver = [BVLabelNode labelWithText:@"Game Over!"];
        gameOver.fontColor = [UIColor whiteColor];
        gameOver.fontSize = BVdynamicFontSizeWithFactor([BVSize screenSize], 0.1);
        gameOver.alpha = 0;
        gameOver.position = CGPointMake(CGRectGetMaxX(self.frame) + CGRectGetWidth(gameOver.frame) / 2, 0);
        
        [gameOver runAction:[SKAction group:@[[SKAction moveTo:CGPointZero duration:0.4],
                                              [SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeAlphaTo:1.0 duration:0.2],
                                                                                                 [SKAction waitForDuration:0.2],
                                                                                                 [SKAction fadeAlphaTo:0.0 duration:0.2],
                                                                                                 [SKAction waitForDuration:0.2]
                                                                                                 ]]]]]];
        // run animation on gameOver label
        
        [_gameOverNode addChild:gameOver];
        
        [self addChild:_gameOverNode];
        
        // add animation
        [_gameOverNode runAction:[SKAction fadeAlphaTo:0.7 duration:0.2]];
    }
}

- (void)removeGameOverNode
{
    // add animation
    [_gameOverNode runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:0.2],
                                                  [SKAction removeFromParent]]]];
    
    //[_gameOverNode removeFromParent];
}


#pragma mark - Animation

- (void)rollRows:(NSTimeInterval)timeElapsed
{
    float speed = [BVSize valueOniPhones:(kGroundScrollSpeed - 50) / 2 andiPads:kGroundScrollSpeed - 50];
    float step = -(timeElapsed * speed);
    
    for (BVPlaygroundRow *row in _objectRows) {
        row.position = CGPointMake(row.position.x + step, row.position.y);
        
        if ([self spriteOutOfBounds:row]) {
            // push to last
            [row setPosRelativeTo:_lastObjectsRow.frame side:BVPosSideRight margin:0 setOtherValue:row.position.y];
            // refill the cells
            [row refillCells];
            // remeber this as the last row
            _lastObjectsRow = row;
        }
    }
    
    SKSpriteNode *firstRow = [_objectRows firstObject];
    SKSpriteNode *lastRow = [_objectRows lastObject];
    
    if (![_lastObjectsRow isEqual:lastRow]) {
        [firstRow setPosRelativeTo:lastRow.frame side:BVPosSideRight margin:0 setOtherValue:lastRow.position.y];
    }
}

- (BOOL)spriteOutOfBounds:(SKSpriteNode *)sprite
{
    float leftEdge = CGRectGetMinX(self.frame);
//    float rightEdge = CGRectGetMaxX(self.frame);
    
    float spriteRightEdge = CGRectGetMaxX(sprite.frame);
//    float spriteLeftEdge = CGRectGetMinX(sprite.frame);
    
    // spriteLeftEdge >= rightEdge ||
    if (spriteRightEdge <= leftEdge) {
        return YES;
    }
    return NO;
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_gameOver) {
        [self restartGame];
    }
    else {
        
        if (!_startedByUser) {
            [self gameStarted];
        }
        
        _hero.physicsBody.velocity = CGVectorMake(0, 0);
        [_hero.physicsBody applyImpulse:CGVectorMake(0, _applyHeroImpulse)];
        
        // play sound
        [self runAction:[BVSounds playgroundPlayerJump]];
        
        // rotate ball with push
        SKAction *rotate = [SKAction rotateByAngle:5 duration:1];
        rotate.timingMode = SKActionTimingEaseOut;
        [_hero runAction:rotate];
        
        if (_hero.physicsBody.velocity.dy > _heroVelocityDyLimit) {
            _hero.physicsBody.velocity = CGVectorMake(0, _heroVelocityDyLimit);
        }
    }
}

#pragma mark - Collision Detection
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (!_gameOver) {
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
        
//        BVPlaygroundHero *hero = (BVPlaygroundHero *)firstBody.node;
        
        if ((secondBody.categoryBitMask & BVPlaygroundPhysicsCategoryGround) != 0) {
            [self gameOver];
        }
        else if ((secondBody.categoryBitMask & BVPlaygroundPhysicsCategorySkyEnd) != 0) {
            // push the ball down
            [_hero.physicsBody applyImpulse:CGVectorMake(0, -5)];
        }
        else if ((secondBody.categoryBitMask & BVPlaygroundPhysicsCategoryObstacle) != 0) {
            // game over
            [self gameOver];
        }
        else if ((secondBody.categoryBitMask & BVPlaygroundPhysicsCategoryCoin) != 0) {
            [secondBody.node removeFromParent];
            _hud.coinsCollected++;
            [self runAction:[BVSounds coin]];
        }
        else if ((secondBody.categoryBitMask & BVPlaygroundPhysicsCategoryCellGateway) != 0) {
            _hud.score++;
        }
    }
}

#pragma mark - Update Loop

- (void)update:(NSTimeInterval)currentTime
{
    static NSTimeInterval lastCallTime;
    NSTimeInterval timeElapsed = currentTime - lastCallTime;
    if (timeElapsed > kMinFPS) {
        timeElapsed = kMinFPS;
    }
    lastCallTime = currentTime;
    
    [_rollingThings rollBigClouds:timeElapsed];
    [_rollingThings rollSmallClouds:timeElapsed];
    
    if (!_stopRolling) {
        [_rollingThings rollGround:timeElapsed];
        
        if (_startedByUser) {
            [self rollRows:timeElapsed];
        }
    }
}
@end
