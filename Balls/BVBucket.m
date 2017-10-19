//
//  BVBucket.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/17/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVBucket.h"
#import "BitMasks.h"
#import "BVColor.h"
#import "UIColor+Mix.h"
#import "BVSize.h"
#import "UIImage+Scaling.h"
#import "BVLabelNode.h"

// work with this issue
typedef enum : NSUInteger {
    BVBucketCategorySolid,
    BVBucketCategoryRGB,
    BVBucketCategoryBomb
} BVBucketCategory;

@implementation BVBucket
{
    SKSpriteNode *_leftSide;
    SKSpriteNode *_rightSide;
    SKSpriteNode *_bucketSensor;
    SKSpriteNode *_bucketCap;
    BVLabelNode *_targetHitLabel;
    BVLabelNode *_targetHitLabelDescription1;
    BVLabelNode *_targetHitLabelDescription2;
    CGSize _bucketSize;
}

@synthesize targetHitLabelCount = _targetHitLabelCount;

#pragma mark - Instantiation
- (instancetype)initWithColor:(nonnull UIColor *)color andAddons:(NSArray *)addons
{
    self = [super init];
    
    if (self) {
        [self setupProps];
        self.name = @"custom-colored";
        self.color = color;
        self.size = _bucketSize;
        self.userData = [NSMutableDictionary dictionary];
        [self.userData setObject:color forKey:@"bucketColor"];
        
        [self setupSidesAndSensor];
        [self addProps];
        
        // if there are any addons then install them now on bucket
        if (addons != nil) {
            for (id obj in addons) {
                
                if ([obj isKindOfClass:[NSNumber class]]) {
                    BVBucketAddon addon = [obj unsignedIntegerValue];
                    
                    switch (addon) {
                        case BVBucketAddonCap:
                            [self addBucketCap];
                            break;
                            
                        case BVBucketAddonLaser:
                            [self addLaserColored:[UIColor redColor]];
                            
                        case BVBucketAddonSpears:
                            //NSLog(@"Spears detected yo!");
                            break;
                            
                        default:
                            break;
                    }
                }
                else if ([obj isKindOfClass:[NSDictionary class]]) {
                    int targetCount = [[obj objectForKey:@"count"] integerValue];
                    self.targetHitLabelCount = targetCount;
                }
            }
        }
    }
    
    return self;
}

- (nonnull instancetype)init
{
    return [BVBucket bucketColored:[BVColor red] withAddons:nil];
}

+ (nonnull instancetype)bucketColored:(UIColor *)color withAddons:(NSArray *)addons
{
    return [[BVBucket alloc] initWithColor:color andAddons:addons];
}

#pragma mark - Sensors
- (void)setupSidesAndSensor
{
    // setup left side
    _leftSide = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1, self.size.height)];
    _leftSide.position = CGPointMake(-(self.size.width / 2), 0);
    _leftSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_leftSide.size];
    _leftSide.physicsBody.affectedByGravity = NO;
    _leftSide.physicsBody.dynamic = NO;
    _leftSide.physicsBody.categoryBitMask = PhysicsCategoryBucket;
    [self addChild:_leftSide];
    
    // setup right side
    _rightSide = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1, self.size.height)];
    _rightSide.position = CGPointMake(self.size.width / 2, 0);
    _rightSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_rightSide.size];
    _rightSide.physicsBody.affectedByGravity = NO;
    _rightSide.physicsBody.dynamic = NO;
    _rightSide.physicsBody.categoryBitMask = PhysicsCategoryBucket;
    [self addChild:_rightSide];
    
    // setup bucket sensor to detect balls
    _bucketSensor = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width / 2, 1)];
    _bucketSensor.name = @"bucketSensor";
    _bucketSensor.position = CGPointZero;
    _bucketSensor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bucketSensor.size];
    _bucketSensor.physicsBody.affectedByGravity = NO;
    _bucketSensor.physicsBody.dynamic = NO;
    _bucketSensor.physicsBody.categoryBitMask = PhysicsCategoryBucketSensor;
    [self addChild:_bucketSensor];
}

- (void)resetSideAndSensorProps
{
    _leftSide.position = CGPointMake(-(self.size.width) / 2, 0);
    _rightSide.position = CGPointMake(self.size.width / 2, 0);
    _bucketSensor.size = CGSizeMake(self.size.width / 2, 1);
    _bucketSensor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bucketSensor.size];
    _bucketSensor.physicsBody.affectedByGravity = NO;
    _bucketSensor.physicsBody.dynamic = NO;
    _bucketSensor.physicsBody.categoryBitMask = PhysicsCategoryBucketSensor;
}

#pragma mark - Bucket Addons

- (void)addBucketCap
{
    // remember that bucket have cap on it
    _hasCap = YES;
    
    _bucketCap = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(self.size.width, self.size.height / 8)];
    _bucketCap.texture = [SKTexture textureWithImage:[[UIImage imageNamed:@"bucket-cap.png"] tiledImageOfSize:_bucketCap.size]];
    _bucketCap.position = CGPointMake(0, CGRectGetMaxY(self.frame) + _bucketCap.size.height / 2);
    _bucketCap.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bucketCap.size];
    _bucketCap.physicsBody.affectedByGravity = NO;
    _bucketCap.physicsBody.dynamic = NO;
    _bucketCap.physicsBody.categoryBitMask = PhysicsCategoryBucketCap;
    [self addChild:_bucketCap];
}

- (void)removeBucketCap
{
    // remember that bucket have no cap anymore.
    _hasCap = NO;
    [_bucketCap removeFromParent];
}

- (void)addLaserColored:(UIColor *)color
{
    UIImage *laserImg = [[UIImage imageNamed:@"bucket-laser-red.png"] tiledImageOfSize:[BVSize resizeUniversally:CGSizeMake(self.size.width, 2) firstTime:YES]];
    SKSpriteNode *laser = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:laserImg]];
    laser.size = CGSizeMake(self.size.width, laser.size.height);
    laser.zPosition = 1.0;
    laser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:laser.size];
    laser.physicsBody.affectedByGravity = NO;
    laser.physicsBody.dynamic = NO;
    laser.physicsBody.categoryBitMask = PhysicsCategoryBucketLaser;
    laser.physicsBody.collisionBitMask = PhysicsCategoryBall;
    
    // save physics state for laser
    laser.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"collisionDetectionEnabled": @YES}];
    
    [self addChild:laser];
    
    // now add laser shooter on right and stopper on the left side
    SKSpriteNode *laserStopper = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:[BVSize resizeUniversally:CGSizeMake(2, 10) firstTime:YES]];
    laserStopper.position = CGPointMake(CGRectGetMinX(self.frame) + (laserStopper.size.width / 2), CGRectGetMaxY(self.frame) + (laserStopper.size.height / 2));
    laserStopper.zPosition = 2.0;
    [self addChild:laserStopper];
    
    SKSpriteNode *laserShooter = [SKSpriteNode spriteNodeWithImageNamed:@"laser-shooter"];
    laserShooter.size = [BVSize resizeUniversally:CGSizeMake(5, 10) firstTime:YES];
    laserShooter.position = CGPointMake(CGRectGetMaxX(self.frame) - (laserShooter.size.width / 2), CGRectGetMaxY(self.frame) + (laserShooter.size.height / 2));
    laserShooter.zPosition = 3.0;
    [self addChild:laserShooter];
    
    // now that we have our laser shooter on screen, it's time to position our laser based on shooter's head
    // calc: topPointOfLaserShooter - halfOfLaser - ((laserShooterHeadHeight - laserHeight) / 2);
    // the last part will position the laser in middle of laserShooterHead
    float laserHeadHeight = [BVSize resizeUniversally:CGSizeMake(0, 3) firstTime:YES].height;
    float laserHeight = laser.size.height;
    float laserPosY = CGRectGetMaxY(laserShooter.frame) - (laserHeight / 2) - ((laserHeadHeight - laserHeight) / 2);
    laser.position = CGPointMake(0, laserPosY);
    
    // play laser animation
    NSNumber *intervalTime = [NSNumber numberWithFloat:0.5];
    
    // start laser animation at random time
    float rand0To1 = drand48();
    
    __weak BVBucket *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, rand0To1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf laserAnimation:@[laser, intervalTime]];
    });
}

- (void)laserAnimation:(NSArray *)args
{
    SKSpriteNode *laser = [args objectAtIndex:0];
    NSNumber *intervalNum = [args objectAtIndex:1];
    
    float interval = [intervalNum floatValue];
    SKAction *showHide = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                              [SKAction runBlock:^{
        _laserActive = NO;
    }],
                                              [SKAction waitForDuration:interval],
                                              [SKAction fadeInWithDuration:0.1],
                                              [SKAction runBlock:^{
        _laserActive = YES;
    }],
                                              [SKAction waitForDuration:interval]]];
    SKAction *loop = [SKAction repeatActionForever:showHide];
    [laser runAction:loop];
}

#pragma mark - Decoration

- (void)addProps
{
//    [self addTargetHitLabel];
    
    SKSpriteNode *bucketCover = [SKSpriteNode spriteNodeWithImageNamed:@"bucket-cover"];
//    [BVSize outputSize:bucketCover.size msg:@"bucketCover"];
//    [BVSize outputSize:self.size msg:@"bucketSize"];
    bucketCover.size = self.size;//CGSizeMake(self.size.width * 1.05, self.size.height * 1.02);
    [self addChild:bucketCover];
}

- (void)addTargetHitLabel
{
    _targetHitLabel = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%i", self.targetHitLabelCount]];
    _targetHitLabel.fontColor = [UIColor whiteColor];
    _targetHitLabel.fontSize = [BVSize valueOniPhones:24 andiPads:34];
    _targetHitLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (CGRectGetHeight(_targetHitLabel.frame)/2));
    [self addChild:_targetHitLabel];
    
    // description label shared props
    float descFontSize = [BVSize valueOniPhones:14 andiPads:24];
    
    // add top description label
    _targetHitLabelDescription1 = [BVLabelNode labelWithText:@"Add"];
    _targetHitLabelDescription1.fontColor = [UIColor colorWithWhite:1 alpha:0.5];
    _targetHitLabelDescription1.fontSize = descFontSize;
    _targetHitLabelDescription1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _targetHitLabelDescription1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(_targetHitLabel.frame) + CGRectGetHeight(_targetHitLabelDescription1.frame)/1.8);
    [self addChild:_targetHitLabelDescription1];
    
    // add bottom description label
    NSString *secondLabelText = (_targetHitLabelCount > 1) ? @"Balls" : @"Ball";
    _targetHitLabelDescription2 = [BVLabelNode labelWithText:secondLabelText];
    _targetHitLabelDescription2.fontColor = [UIColor colorWithWhite:1 alpha:0.5];
    _targetHitLabelDescription2.fontSize = descFontSize;
    _targetHitLabelDescription2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _targetHitLabelDescription2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(_targetHitLabel.frame) - CGRectGetHeight(_targetHitLabelDescription2.frame)/1.8);
    [self addChild:_targetHitLabelDescription2];
}

#pragma mark - Gettter & Setter Methods

- (void)setTargetHitLabelCount:(int)targetHitCountLabel
{
    _targetHitLabelCount = (targetHitCountLabel < 0) ? 0 : targetHitCountLabel;
    
    if (!_targetHitLabel && _targetHitLabelCount > 0) {
        [self addTargetHitLabel];
    }
    
    if (targetHitCountLabel == 0) {
        // hide description labels
        [_targetHitLabelDescription1 runAction:[SKAction fadeOutWithDuration:0.1]];
        [_targetHitLabelDescription2 runAction:[SKAction fadeOutWithDuration:0.1]];
        
        // hide the target hit label
        [_targetHitLabel runAction:[SKAction fadeOutWithDuration:0.2] completion:^{
            // TODO: Animate checkmark
            
            // present white checkmark in the middle
            SKAction *decisionAnimation = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:0.1],
                                                               [SKAction scaleTo:1.0 duration:0.1]]];
            
            // Add checkmark animation for hitting bucket's target
            SKSpriteNode *checkmark = [SKSpriteNode spriteNodeWithImageNamed:@"tick"];
            checkmark.name = @"checkmark";
            checkmark.position = CGPointZero;
            checkmark.size = [BVSize resizeUniversally:CGSizeMake(20, 14) firstTime:YES];
            [checkmark setScale:0.0];
            [self addChild:checkmark];
            
            // run the animation
            [checkmark runAction:decisionAnimation];
        }];
    }
    else if (targetHitCountLabel == -1) {
        // hide the target hit label since this bucket is no longer a target bucket. (user made a mistake)
        [_targetHitLabel runAction:[SKAction fadeOutWithDuration:0.2]];
        // also hide the description labels
        [_targetHitLabelDescription1 runAction:[SKAction fadeOutWithDuration:0.1]];
        [_targetHitLabelDescription2 runAction:[SKAction fadeOutWithDuration:0.1]];
    }
    else {
        _targetHitLabel.text = [NSString stringWithFormat:@"%i", targetHitCountLabel];
        _targetHitLabelDescription2.text = (_targetHitLabelCount > 1) ? @"Balls" : @"Ball";
    }
}

#pragma mark - Utility Methods

- (void)setupProps
{
    float factor = CGRectGetHeight([UIScreen mainScreen].bounds) * 0.09;
    _bucketSize = [BVSize sizeOniPhones:CGSizeMake(factor, factor + (factor / 3)) andiPads:CGSizeMake(factor * 1.1, factor + (factor / 3))];
}
@end
