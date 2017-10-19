//
//  BVPlaygroundObject.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVPlaygroundObject.h"
#import "BVPlaygroundBitmasks.h"
#import "BVColor.h"
#import "BVSize.h"

@implementation BVPlaygroundObject

+ (instancetype)Blank
{
    BVPlaygroundObject *obj = [[BVPlaygroundObject alloc] initWithObjectType:BVPlaygroundObjectTypeBlank];
    obj.color = [UIColor clearColor];
    return obj;
}

+ (instancetype)Spikes
{
    BVPlaygroundObject *obj = [[BVPlaygroundObject alloc] initWithObjectType:BVPlaygroundObjectTypeObstacle];
    obj.color = [BVColor r:118 g:77 b:2];
    [obj applyChanges];
    return obj;
}

+ (instancetype)Coin
{
    BVPlaygroundObject *obj = [[BVPlaygroundObject alloc] initWithObjectType:BVPlaygroundObjectTypeCoin];
    obj.color = [BVColor yellow];
    [obj applyChanges];
    return obj;
}

- (instancetype)initWithObjectType:(BVPlaygroundObjectType)type
{
    self = [super init];
    
    if (self) {
        self.name = @"playground-object";
        self.type = type;
    }
    
    return self;
}

- (void)applyChanges
{
    switch (_type) {
        case BVPlaygroundObjectTypeObstacle:
            [self generateObstacleObject];
            break;
            
        case BVPlaygroundObjectTypeCoin:
            [self generateCoinObject];
            break;
    }
    
    [self setupPhysicsWithSize:self.size];
}

- (void)generateObstacleObject
{
    self.texture = [SKTexture textureWithImageNamed:@"vertical-blocks.png"];
    self.size = [BVSize resizeUniversally:CGSizeMake(50, 130) firstTime:YES];
}

- (void)generateCoinObject
{
    self.texture = [SKTexture textureWithImageNamed:@"Coin"];
    self.size = [BVSize resizableSizeOniPhones:CGSizeMake(30, 30) andiPads:CGSizeMake(25, 25)];
}

- (void)globalPhysicsProps
{
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = NO;
}

#pragma mark - Utility Methods

- (void)setupPhysicsWithSize:(CGSize)size
{
    if (_type == BVPlaygroundObjectTypeObstacle) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.categoryBitMask = BVPlaygroundPhysicsCategoryObstacle;
    }
    else if (_type == BVPlaygroundObjectTypeCoin) {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size.width / 2];
        self.physicsBody.categoryBitMask = BVPlaygroundPhysicsCategoryCoin;
    }
    
    [self globalPhysicsProps];
}

#pragma mark - Getter & Setter
- (void)setSize:(CGSize)size
{
    [super setSize:size];
    [self setupPhysicsWithSize:size];
}

@end
