//
//  BVFlyingObjectsCreator.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVFlyingObject.h"
#import "BitMasks.h"
#import "BVSize.h"
#import "BVLabelNode.h"
#import "UIImage+Scaling.h"
#import "BVColor.h"
#import "SKSpriteNode+BVPos.h"

@interface BVFlyingObject ()

@property (nonatomic) BOOL startBlinkingRandomly; // only used with blinking spikes object

@end

@implementation BVFlyingObject
{
    BOOL _noPhysics;
    SKSpriteNode *_cap; // only available on certain objects
    CGSize _screenSize;
}

#pragma mark - Create Objects With Style

+ (instancetype)Points:(int)givePoints withCap:(BOOL)withCap flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObjectType type;
    
    if (withCap) {
        type = BVFlyingObjectTypePointsWithCap;
    }
    else {
        type = BVFlyingObjectTypePoints;
    }
    
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:type];
    obj.givePoints = givePoints;
    obj.name = @"points";
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (instancetype)Points:(int)givePoints withCap:(BOOL)withCap
{
    return [BVFlyingObject Points:givePoints withCap:withCap flyOptions:@{}];
}

+ (instancetype)Timer:(int)seconds withCap:(BOOL)withCap flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObjectType type;
    
    if (withCap) {
        type = BVFlyingObjectTypeTimerWithCap;
    } else {
        type = BVFlyingObjectTypeTimer;
    }
    
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:type];
    obj.giveTime = seconds;
    obj.name = @"time";
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (instancetype)Timer:(int)seconds withCap:(BOOL)withCap
{
    return [BVFlyingObject Timer:seconds withCap:withCap flyOptions:@{}];
}

+ (instancetype)SpikesWithBlinkInterval:(float)blinkingInterval flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObject *obj = [BVFlyingObject SpikesWithBlinkInterval:blinkingInterval startRandomly:NO];
    [self setupFlyOptions:flyOptions of:obj];
    return obj;
}

+ (instancetype)SpikesWithBlinkInterval:(float)blinkingInterval
{
    return [BVFlyingObject SpikesWithBlinkInterval:blinkingInterval flyOptions:@{}];
}

+ (nonnull instancetype)SpikesWithBlinkInterval:(float)blinkingInterval startRandomly:(BOOL)startRandomly flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:BVFlyingObjectTypeObstacle];
    obj.name = @"spikes";
    obj.obstacleType = BVFlyingObjectObstacleTypeSpikes;
    obj.blinkingInterval = blinkingInterval;
    obj.startBlinkingRandomly = startRandomly;
    
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (nonnull instancetype)SpikesWithBlinkInterval:(float)blinkingInterval startRandomly:(BOOL)startRandomly
{
    return [BVFlyingObject SpikesWithBlinkInterval:blinkingInterval startRandomly:startRandomly flyOptions:@{}];
}

+ (instancetype)GiveBallType:(BVBallType)ballType color:(UIColor *)ballColored quantity:(int)quantityOfBallsToGive flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:BVFlyingObjectTypeBallAdder];
    obj.ballType = ballType;
    obj.givesBallOfType = ballType;
    obj.ballColor = ballColored;
    obj.quantityOfBallsToGive = quantityOfBallsToGive;
    obj.name = @"ball-adder";
    
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (instancetype)GiveBallType:(BVBallType)ballType color:(UIColor *)ballColored quantity:(int)quantityOfBallsToGive
{
    return [BVFlyingObject GiveBallType:ballType color:ballColored quantity:quantityOfBallsToGive flyOptions:@{}];
}

+ (instancetype)RowSpeedIncreaseBy:(int)inBy decreaseBy:(int)deBy flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:BVFlyingObjectTypeRowSpeedModifier];
    obj.name = @"row-speed-modifier";
    obj.increaseRowSpeedBy = inBy;
    obj.decreaseRowSpeedBy = deBy;
    
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (instancetype)RowSpeedIncreaseBy:(int)by flyOptions:(NSDictionary *)flyOptions
{
    return [BVFlyingObject RowSpeedIncreaseBy:by decreaseBy:0 flyOptions:flyOptions];
}

+ (instancetype)RowSpeedDecreaseBy:(int)by flyOptions:(NSDictionary *)flyOptions
{
    return [BVFlyingObject RowSpeedIncreaseBy:0 decreaseBy:by flyOptions:flyOptions];
}

+ (instancetype)RowSpeedIncreaseBy:(int)by
{
    return [BVFlyingObject RowSpeedIncreaseBy:by decreaseBy:0 flyOptions:@{}];
}

+ (instancetype)RowSpeedDecreaseBy:(int)by
{
    return [BVFlyingObject RowSpeedIncreaseBy:0 decreaseBy:by flyOptions:@{}];
}

+ (instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope blinkingInt:(float)blinkingInterval startRandomly:(BOOL)startRandomly flyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:BVFlyingObjectTypeRightAngleStop];
    obj.name = @"right-angle";
    obj.slopeOnRightSide = rightSlope;
    obj.blinkingInterval = blinkingInterval;
    obj.startBlinkingRandomly = startRandomly;
    
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope blinkingInt:(float)blinkingInterval startRandomly:(BOOL)startRandomly
{
    return [BVFlyingObject RightAngleStopWithRightSlope:rightSlope blinkingInt:blinkingInterval startRandomly:startRandomly flyOptions:@{}];
}

+ (instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope flyOptions:(NSDictionary *)flyOptions
{
    return [BVFlyingObject RightAngleStopWithRightSlope:rightSlope blinkingInt:0 startRandomly:NO flyOptions:flyOptions];
}

+ (instancetype)RightAngleStopWithRightSlope:(BOOL)rightSlope
{
    return [BVFlyingObject RightAngleStopWithRightSlope:rightSlope flyOptions:@{}];
}

+ (instancetype)SurpriseWithFlyOptions:(NSDictionary *)flyOptions
{
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:BVFlyingObjectTypeSurprise];
    obj.name = @"surprise";
    
    [self setupFlyOptions:flyOptions of:obj];
    [obj applyChanges];
    
    return obj;
}

+ (instancetype)Surprise
{
    return [BVFlyingObject SurpriseWithFlyOptions:@{}];
}

+ (instancetype)Blank
{
    BVFlyingObject *obj = [[BVFlyingObject alloc] initWithObjectType:BVFlyingObjectTypeBlank];
    obj.name = @"blank";
    [obj applyChanges];
    
    return obj;
}

#pragma mark - Helpers
+ (void)setupFlyOptions:(NSDictionary *)flyOptions of:(BVFlyingObject *)obj
{
    int flyAreaOnLeft = [[flyOptions objectForKey:@"l"] intValue];
    int flyAreaOnRight = [[flyOptions objectForKey:@"r"] intValue];
    int flySpeedChangeBy = [[flyOptions objectForKey:@"speedBy"] intValue];
    
    obj.flyAreaOnLeft = flyAreaOnLeft;
    obj.flyAreaOnRight = flyAreaOnRight;
    obj.flySpeedChangeBy = flySpeedChangeBy;
}

#pragma mark - Initializer

- (instancetype)initWithObjectType:(BVFlyingObjectType)type
{
    self = [super init];
    
    if (self) {
        
        // by default we're enabling physics on all objects
        _noPhysics = NO;
        _screenSize = [BVSize screenSize];
        
        self.color = [UIColor redColor];
        float objWidth = [BVSize valueOniPhone4s:59.5 iPhone5To6sPlus:53.333333 iPad:64];
        self.size = [BVSize resizeUniversally:[BVSize sizeOniPhones:CGSizeMake(objWidth, 20) andiPads:CGSizeMake(objWidth, 24)] firstTime:YES];
        self.type = type;
    }
    
    return self;
}

- (void)applyChanges
{
    switch (_type) {
        case BVFlyingObjectTypePoints:
            [self generatePointsObjectWithCap:NO];
            break;
            
        case BVFlyingObjectTypePointsWithCap:
            [self generatePointsObjectWithCap:YES];
            break;
            
        case BVFlyingObjectTypeObstacle:
            [self generateObstacleObject];
            break;
            
        case BVFlyingObjectTypeBallAdder:
            [self generateBallAdderObject];
            break;
            
        case BVFlyingObjectTypeTimer:
            [self generateTimerObjectWithCap:NO];
            break;
            
        case BVFlyingObjectTypeTimerWithCap:
            [self generateTimerObjectWithCap:YES];
            break;
            
        case BVFlyingObjectTypeRowSpeedModifier:
            [self generateRowSpeedModifierObject];
            break;
            
        case BVFlyingObjectTypeRightAngleStop:
            [self generateRightAngleStopObject];
            break;
            
        case BVFlyingObjectTypeSurprise:
            [self generateSurpriseObject];
            break;
            
        case BVFlyingObjectTypeBlank:
            [self generateBlankObject];
            break;
    }
    
    if (!_noPhysics) {
        [self globalPhysicsProps];
    }
}

#pragma mark - Object Design

- (void)generatePointsObjectWithCap:(BOOL)withCap
{
    self.color = [UIColor colorWithWhite:1 alpha:0.5];
    UIColor *pointsLabelColor = [BVColor red];
    NSString *pointsPrefix = @"";
    
    if (self.givePoints > 0) {
        pointsPrefix = @"+";
        pointsLabelColor = [BVColor green];
    }
    
    // create a points label
    BVLabelNode *points = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%@%i", pointsPrefix, _givePoints]];
    points.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    points.fontColor = pointsLabelColor;
    points.fontSize = BVdynamicFontSizeWithFactor(_screenSize, 0.046);
    [self addChild:points];
    
    // setup physics
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    
    if (withCap) {
        CGSize capSize = CGSizeMake(self.size.width, self.size.height / 3);
        SKTexture *capTexture = [SKTexture textureWithImage:[[UIImage imageNamed:@"bucket-cap"] tiledImageOfSize:capSize]];
        _cap = [SKSpriteNode spriteNodeWithTexture:capTexture size:capSize];
        _cap.position = CGPointMake(0, CGRectGetMaxY(self.frame) - (_cap.size.height / 2));
        [self addChild:_cap];
        
        // make points label font little smaller because of the cap on the top
        points.fontSize = BVdynamicFontSizeWithFactor(_screenSize, 0.042); // 14.0f on iphone5
        
        // and move it down a bit
        float pointsY = (self.size.height - capSize.height) / 2;
        float objHeightHalf = CGRectGetHeight(self.frame) / 2;
        pointsY = pointsY - objHeightHalf;
        points.position = CGPointMake(0, pointsY);
    }
}

- (void)generateObstacleObject
{
    if (self.obstacleType == BVFlyingObjectObstacleTypeSpikes) {
        self.texture = [SKTexture textureWithImageNamed:@"FlyingObj-Spikes"];
        
        __weak BVFlyingObject *weakSelf = self;
        // setup blinking animation if required
        if (_blinkingInterval) {
            if (_startBlinkingRandomly) {
                float rand0To1 = drand48();
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, rand0To1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [weakSelf startBlinkingAnimation];
                });
            }
            else {
                [self startBlinkingAnimation];
            }
        }
        
        // setup physics
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    }
}

- (void)generateBallAdderObject
{
    SKSpriteNode *holder = [SKSpriteNode node];
    CGFloat fontSize = BVdynamicFontSizeWithFactor(_screenSize, 0.046);
    // only use for BVBallTypeBomb;
    SKSpriteNode *bomb;
    
    // only used for BVBallTypeColored;
    BVLabelNode *ballGivingLabel;
    
    // create balls label
    NSString *labelText = [NSString stringWithFormat:@"+%i", _quantityOfBallsToGive];
    BVLabelNode *ballsLabel;
    
    if (_ballType == BVBallTypeBomb) {
        self.color = [BVColor yellow];
        
        // setup balls label
        ballsLabel = [BVLabelNode labelWithText:labelText color:[UIColor blackColor] size:fontSize shadowColor:[UIColor clearColor] offSetX:0 offSetY:0];

        bomb = [SKSpriteNode spriteNodeWithImageNamed:@"bomb-small"];
        bomb.size = CGSizeMake(self.size.height, self.size.height / 1.2);
        [bomb setPosRelativeTo:ballsLabel.frame side:BVPosSideLeft margin:2];
        //bomb.position = CGPointMake(CGRectGetMinX(self.frame) + (bomb.size.width / 2), 0);
        [holder addChild:bomb];
    } else {
        self.color = _ballColor;
        
        // setup balls label
        ballsLabel = [BVLabelNode labelWithText:labelText color:[UIColor whiteColor] size:fontSize shadowColor:[UIColor blackColor] offSetX:-1 offSetY:-1];
        
        ballGivingLabel = [BVLabelNode labelWithText:@"Ball " color:[UIColor whiteColor] size:fontSize shadowColor:[UIColor blackColor] offSetX:-1 offSetY:-1];
        [holder addChild:ballGivingLabel];
    }
    
    [holder addChild:ballsLabel];
    
    // update holder size
    holder.size = [holder calculateAccumulatedFrame].size;
    
    // reposition ballsLabel and bomb icon
    ballsLabel.position = (_ballType == BVBallTypeBomb) ?  CGPointMake(CGRectGetMaxX(holder.frame) - (CGRectGetWidth(ballsLabel.frame) / 2), 0) : CGPointMake(CGRectGetMaxX(holder.frame), 0);
    bomb.position = CGPointMake(CGRectGetMinX(holder.frame) + (bomb.size.width / 2), 0);
    ballGivingLabel.position = CGPointMake(CGRectGetMinX(holder.frame) + (CGRectGetWidth(ballGivingLabel.frame) / 6), 0);
    
    [self addChild:holder];
    
    // setup physics
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
}

- (void)generateTimerObjectWithCap:(BOOL)withCap
{
    self.color = [UIColor colorWithWhite:1 alpha:0.5];
    UIColor *timerLabelColor = [BVColor red];
    NSString *timePrefix = @"";
    
    if (self.giveTime > 0) {
        timePrefix = @"+";
        timerLabelColor = [BVColor green];
    }
    
    // create a points label
    BVLabelNode *time = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%@%i sec", timePrefix, _giveTime]];
    time.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    time.fontColor = timerLabelColor;
    time.fontSize = BVdynamicFontSizeWithFactor(_screenSize, 0.046);
    [self addChild:time];
    
    // setup physics
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    
    if (withCap) {
        CGSize capSize = CGSizeMake(self.size.width, self.size.height / 3);
        SKTexture *capTexture = [SKTexture textureWithImage:[[UIImage imageNamed:@"bucket-cap"] tiledImageOfSize:capSize]];
        _cap = [SKSpriteNode spriteNodeWithTexture:capTexture size:capSize];
        _cap.position = CGPointMake(0, CGRectGetMaxY(self.frame) - (_cap.size.height / 2));
        [self addChild:_cap];
        
        // make points label font little smaller because of the cap on the top
        time.fontSize = BVdynamicFontSizeWithFactor(_screenSize, 0.042); // 14.0f on iphone5
        
        // and move it down a bit
        float pointsY = (self.size.height - capSize.height) / 2;
        float objHeightHalf = CGRectGetHeight(self.frame) / 2;
        pointsY = pointsY - objHeightHalf;
        time.position = CGPointMake(0, pointsY);
    }
}

- (void)generateRowSpeedModifierObject
{
    self.color = [UIColor redColor];
    
    NSString *labelText = (_increaseRowSpeedBy) ? [NSString stringWithFormat:@"%ix", _increaseRowSpeedBy] : [NSString stringWithFormat:@"-%ix", _decreaseRowSpeedBy];
    BVLabelNode *byLabel = [BVLabelNode labelWithText:labelText];
    byLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    byLabel.fontColor = [UIColor whiteColor];
    byLabel.fontSize = BVdynamicFontSizeWithFactor(_screenSize, 0.046);
    [self addChild:byLabel];
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
}

- (void)generateRightAngleStopObject
{
    self.color = [UIColor clearColor];
    
    // setup physics here
    CGMutablePathRef path = CGPathCreateMutable();
    
    float minX = CGRectGetMinX(self.frame);
    float maxX = CGRectGetMaxX(self.frame);
    float minY = CGRectGetMinY(self.frame);
    float maxY = CGRectGetMaxY(self.frame);
    
    if (_slopeOnRightSide) {
        CGPathMoveToPoint(path, NULL, minX, minY);
        CGPathAddLineToPoint(path, NULL, maxX, minY);
        CGPathAddLineToPoint(path, NULL, minX, maxY);
    }
    else {
        CGPathMoveToPoint(path, NULL, maxX, minY);
        CGPathAddLineToPoint(path, NULL, minX, minY);
        CGPathAddLineToPoint(path, NULL, maxX, maxY);
    }
    
    CGPathCloseSubpath(path);
    
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    self.physicsBody.categoryBitMask = PhysicsCategoryFlyingObjectWithBallCollision;
    
    
    // add right angle graphic.
    SKShapeNode *rightAngledTriangle = [SKShapeNode shapeNodeWithPath:path];
    rightAngledTriangle.fillColor = [BVColor r:130 g:88 b:25];
    rightAngledTriangle.strokeColor = [BVColor r:118 g:77 b:2];
    
    [self addChild:rightAngledTriangle];
    
    __weak BVFlyingObject *weakSelf = self;
    
    // setup blinking animation if required
    if (_blinkingInterval) {
        if (_startBlinkingRandomly) {
            float rand0To1 = drand48();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, rand0To1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf blinkAndStopCollisionDetectionWhenHidden:YES];
            });
        }
        else {
            [self blinkAndStopCollisionDetectionWhenHidden:YES];
        }
    }
    
    CGPathRelease(path);
}

- (void)generateSurpriseObject
{
    self.color = [UIColor purpleColor];
    
    // setup physics
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
}

- (void)generateBlankObject
{
    self.color = [UIColor clearColor];
    // we don't need any physics for this object
    _noPhysics = YES;
}

- (void)blinkAndStopCollisionDetectionWhenHidden:(BOOL)stopCollisionDetection
{
    SKAction *blink;
    
    if (stopCollisionDetection) {
        __weak BVFlyingObject *weakSelf = self;
        blink = [SKAction sequence:@[[SKAction waitForDuration:_blinkingInterval],
                                     [SKAction fadeAlphaTo:0 duration:0.2],
                                     [SKAction runBlock:^{
            weakSelf.physicsBody.categoryBitMask = PhysicsCategoryFlyingObject;
        }],
                                     [SKAction waitForDuration:_blinkingInterval],
                                     [SKAction fadeAlphaTo:1 duration:0.2],
                                     [SKAction runBlock:^{
            weakSelf.physicsBody.categoryBitMask = PhysicsCategoryFlyingObjectWithBallCollision;
        }]]];
    }
    else {
        blink = [SKAction sequence:@[[SKAction waitForDuration:_blinkingInterval],
                                     [SKAction fadeAlphaTo:0 duration:0.2],
                                     [SKAction waitForDuration:_blinkingInterval],
                                     [SKAction fadeAlphaTo:1 duration:0.2]]];
    }
    
    SKAction *blinking = [SKAction repeatActionForever:blink];
    
    [self runAction:blinking];
}

- (void)startBlinkingAnimation
{
    [self blinkAndStopCollisionDetectionWhenHidden:NO];
}

#pragma mark - Object Transformation

- (void)transformIntoBlankObject
{
    self.name = @"blank";
    self.color = [UIColor clearColor];
    self.physicsBody = nil;
    self.type = BVFlyingObjectTypeBlank;
    self.givesBallOfType = BVBallTypeClear;
    
    [self removeAllChildren];
}

#pragma mark - Physics Related

- (void)globalPhysicsProps
{
    if (self.physicsBody.categoryBitMask != PhysicsCategoryFlyingObjectWithBallCollision) {
        self.physicsBody.categoryBitMask = PhysicsCategoryFlyingObject;
    }
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = NO;
}

#pragma mark - Object Cap Methods

- (BOOL)isCapped
{
    return (_cap != nil);
}

- (void)destroyCap
{
    [_cap removeFromParent];
    _cap = nil;
}
@end
