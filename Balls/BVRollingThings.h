//
//  BVRollingThings.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/4/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVRollingThings : SKSpriteNode

@property (nonatomic) NSArray *groundTextures;
@property (nonatomic) NSArray *bigCloudTextures;
@property (nonatomic) NSArray *smallCloudTextures;
@property (nonatomic, weak) SKNode *parentNode;

- (void)addGrassyGround;
- (void)addClouds;
- (void)addCloudsForLevels;
- (nonnull SKSpriteNode *)grass;
- (void)rollBigClouds:(NSTimeInterval)timeElapsed;
- (void)rollSmallClouds:(NSTimeInterval)timeElapsed;
- (void)rollGround:(NSTimeInterval)timeElapsed;

@end
