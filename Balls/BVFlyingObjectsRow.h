//
//  BVFlyingObjectsRow.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class BVFlyingObject;

@interface BVFlyingObjectsRow : SKSpriteNode

@property (nonatomic) int scrollingDirection;
@property (nonatomic) int scrollingSpeed;
@property (nonatomic, weak, nullable) BVFlyingObject *lastFlyingObject;
@property (nonatomic) BOOL isBackAndForthRow;

- (nonnull instancetype)initWithScrollingSpeed:(int)scrollingSpeed andDirection:(int)scrollingDirection;

@end
