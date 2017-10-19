//
//  BVSounds.h
//  BallSpectrum
//
//  Created by Bhawan Virk on 2/9/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@import AVFoundation;

@interface BVSounds : NSObject

#pragma mark - Instance
+ (BVSounds *)sharedInstance;

#pragma mark - Music Controls
- (void)playMusic;
- (void)stopMusic;

#pragma mark - Level Sounds
+ (SKAction *)levelPassed;
+ (SKAction *)targetBucketHit;
+ (SKAction *)bomb;
+ (SKAction *)ballPops;
+ (SKAction *)ballTap;
+ (SKAction *)bucketLaser;
+ (SKAction *)ballDropInBucket;
+ (SKAction *)flyingObjectBanner;

#pragma mark - Playground Sounds
+ (SKAction *)playgroundPlayerJump;
+ (SKAction *)playgroundCollision;
+ (SKAction *)coin;

#pragma mark - Misc Sounds
+ (SKAction *)tap;

@end
