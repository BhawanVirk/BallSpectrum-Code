//
//  BVBall.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 6/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVBall.h"
#import "BitMasks.h"
#import "BVColor.h"
#import "UIColor+Mix.h"
#import "BVLevel.h"
#import "BVSize.h"
#import "BVParticle.h"
#import "BVSounds.h"

@interface BVBall ()

@property (nonatomic, strong) NSMutableString *imgName;

@end

@implementation BVBall
{
    float _ballSize;
    NSMutableString *_textureImageName;
    CGPoint _touchStartPos;
    CGPoint _touchEndPos;
}

#pragma mark - Instantiation Methods

+ (nonnull instancetype)solidRed
{
    return [[BVBall alloc] initWithColor:[BVColor red]];
}

+ (nonnull instancetype)solidGreen
{
    return [[BVBall alloc] initWithColor:[BVColor green]];
}

+ (nonnull instancetype)solidYellow
{
    return [[BVBall alloc] initWithColor:[BVColor yellow]];
}

+ (nonnull instancetype)solidBlue
{
    return [[BVBall alloc] initWithColor:[BVColor blue]];
}

+ (nonnull instancetype)solidOrange
{
    return [[BVBall alloc] initWithColor:[BVColor orange]];
}

+ (nonnull instancetype)solidViolet
{
    return [[BVBall alloc] initWithColor:[BVColor violet]];
}

+ (nonnull instancetype)clearBall
{
    return [BVBall ballWithType:BVBallTypeClear];
}

+ (nonnull instancetype)dummyBall
{
    return [BVBall ballWithType:BVBallTypeDummy];
}

+ (nonnull instancetype)ballWithMixtureOfColor1:(UIColor *)color1 andColor2:(UIColor *)color2
{
    UIColor *color = [UIColor colorBetweenColor:color1 andColor:color2 percentage:0.5];
    return [[BVBall alloc] initWithColor:color];
}

+ (nonnull instancetype)ballWithType:(BVBallType)type
{
    return [[BVBall alloc] initWithBallType:type];
}

+ (nonnull instancetype)ballColored:(UIColor *)color
{
    return [[BVBall alloc] initWithColor:color];
}

- (instancetype)initWithColor:(nonnull UIColor *)color
{
    self = [super init];
    
    if (self) {
        
        // this method MUST go before calling setupPhysics:, because we're setting size of the ball in it and then using the size in setupPhysics.
        [self setupProps];
        [self setupPhysics];
        
        // setup properties
        [self setupBallWithColor:color];
        
        // enable touches
        self.userInteractionEnabled = YES;
        
        [self addBallCover];
    }
    
    return self;
}

- (nonnull instancetype)initWithBallType:(BVBallType)type
{
    self = [super init];
    
    if (self) {
        
        [self setupProps];
        [self setupPhysics];
        
        // customize contact and collision detection based on type
        
        switch (type) {
                
            case BVBallTypeColored:
                
                [self setupBallWithColor:[BVColor red]];
                
                break;
                
            case BVBallTypeBomb:
                
                self.name = @"ball-bomb";
                self.color = [UIColor blackColor];
                self.texture = [SKTexture textureWithImageNamed:@"bomb-ball"];//[SKTexture textureWithImage:[self ballTextureWithColor:[UIColor blackColor]]];
                self.type = BVBallTypeBomb;
                self.physicsBody.contactTestBitMask = PhysicsCategoryBallDestroyer | PhysicsCategoryBucketCap | PhysicsCategoryBucketLaser | PhysicsCategoryFlyingObject;
                [self addBombSpark];
                
                break;
                
            case BVBallTypeClear:
                
                self.name = @"ball-clear";
                self.color = [UIColor clearColor];
                self.type = BVBallTypeClear;
                
                break;
                
            case BVBallTypeDummy:
                
                self.name = @"ball-dummy";
                self.color = [UIColor clearColor];//[UIColor grayColor];
                self.type = BVBallTypeDummy;
                self.physicsBody = nil;
                
                break;
                
            default:
                break;
        }
        
        // enable touches
        self.userInteractionEnabled = YES;
        
        [self addBallCover];
    }
    
    return self;
}

- (nonnull instancetype)init
{
    return [self initWithColor:[BVColor red]];
}

#pragma mark - Touch methods
- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    if (self.rack) {
        [self.rack touchesBegan:touches withEvent:event];
    }
    
    _touchStartPos = [[touches anyObject] locationInNode:self];
    
    // squish the ball
    [self setScale:0.9];
}

- (void)touchesMoved:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    if (self.rack) {
        [self.rack touchesMoved:touches withEvent:event];
    }
    //[super touchesMoved:touches withEvent:event];
    _touchEndPos = [[touches anyObject] locationInNode:self];
}

- (void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    // scale back to normal scale with animation
    [self runAction:[SKAction scaleTo:1.0 duration:0.1]];
    
    if (self.rack) {
        [self.rack touchesEnded:touches withEvent:event];
    }
    
    _touchEndPos = [[touches anyObject] locationInNode:self];
    
    float diff = fabs(_touchEndPos.x - _touchStartPos.x);
    //NSLog(@"DIFF: %f", diff);
    
    if (diff < 10) {
        [self removeAndRelease];
    }
    
    // reset touch values
    _touchStartPos = CGPointZero;
    _touchEndPos = CGPointZero;
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    NSLog(@"touch cancelled");
}

- (void)removeAndRelease
{
    // play tap sound
    [self runAction:[BVSounds ballTap]];
    
    SKNode *invisbleBallHandler = [self.scene childNodeWithName:@"invisibleBallHandler"];//[self childNodeWithName:@"//invisibleBallHandler"];
    
    // convert current coordinates to invisibleBallHandlers coord space, So that ball maintains it's current position in view, even though it's moved to a new parent.
    CGPoint posInHandler = [self.parent convertPoint:self.position toNode:invisbleBallHandler];
    
    // remove it from rack
    [self removeFromParent];
    
    // update the position
    self.position = posInHandler;
    
    // make it a child of handler
    [invisbleBallHandler addChild:self];
    
    // disable any further touches as they will recall this method
    self.userInteractionEnabled = NO;
    // IMPORTANT: Only set self.rack = nil after stopping touches because, we're using
    //            rack property in touch handling methods. And if we set it to nil before even stopping touches,
    //            then there is a possibility of EXC_BAD_ACCESS error if user have touched the ball in the process where
    //            we yet to stop touches.
    // now remove reference to rack. (because strong references keeps the object in memory)
    self.rack = nil;
    
    // TODO: work here to check if applying force rather than depening on gravity push brings better performance.
    self.physicsBody.affectedByGravity = YES;
    
    // Post a ball released notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BVBallGotReleased" object:self];
}

#pragma mark - Utility Methods

- (void)setupBallWithColor:(UIColor *)color
{
    self.name = @"ball-colored";
    self.color = color;
    self.texture = [SKTexture textureWithImage:[self ballTextureWithColor:color]];
    self.type = BVBallTypeColored;
}

- (void)setupPhysics
{
    // create physics body
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2];
    self.physicsBody.affectedByGravity = NO;
    
    // setup contact bitmask
    self.physicsBody.categoryBitMask = PhysicsCategoryBall;
    self.physicsBody.contactTestBitMask = PhysicsCategoryBucketSensor | PhysicsCategoryBallDestroyer | PhysicsCategoryBucketCap | PhysicsCategoryBucketLaser | PhysicsCategoryFlyingObject;
    self.physicsBody.collisionBitMask = PhysicsCategoryBucket;
}

- (void)enableCollisionWithOtherBalls
{
    self.physicsBody.collisionBitMask = PhysicsCategoryBucket | PhysicsCategoryBall | PhysicsCategoryFlyingObjectWithBallCollision;
}

- (void)setupProps
{
    // we're setting size here because this method is being used in two initializer methods. We don't want to copy and paste the size calculations in both initializers.
    float factor = [BVSize valueOniPhone4s:0.071 iPhone5To6sPlus:0.071 iPad:0.071];
    _ballSize = CGRectGetHeight([UIScreen mainScreen].bounds) * factor;
    self.size = CGSizeMake(_ballSize, _ballSize);
}

- (UIImage *)ballTextureWithColor:(UIColor *)color
{
    UIImage *ball = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    ball = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(ctx);
//    UIGraphicsEndImageContext();
    
    return ball;
}

- (void)addBallCover
{
    // seeing no real difference in look, so disabling the following code
    SKSpriteNode *ballCover = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ball-cover"] size:self.size];
    ballCover.zPosition = self.zPosition + 1;
    [self addChild:ballCover];
}

- (void)addBombSpark
{
    SKEmitterNode *bombSpark = [BVParticle BombSpark];
    bombSpark.zPosition = 2;
    bombSpark.position = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
    if (bombSpark) {
        [self addChild:bombSpark];
    }
}

@end
