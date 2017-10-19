//
//  BVPlaygroundHero.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVPlaygroundHero : SKSpriteNode

- (nonnull instancetype)initWithColor:(nonnull UIColor *)color;
- (void)noMoreCollision;

@end
