//
//  BVPlaygroundObject.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BVPlaygroundObjectType) {
    BVPlaygroundObjectTypeObstacle,
    BVPlaygroundObjectTypeCoin,
    BVPlaygroundObjectTypeBlank
};

@interface BVPlaygroundObject : SKSpriteNode

@property (nonatomic) BVPlaygroundObjectType type;

+ (nonnull instancetype)Blank;
+ (nonnull instancetype)Spikes;
+ (nonnull instancetype)Coin;

@end
