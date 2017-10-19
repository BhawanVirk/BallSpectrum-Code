//
//  BVParticle.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/5/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVParticle : SKEmitterNode

+ (nonnull SKEmitterNode *)loadFile:(nonnull NSString *)fileName;
+ (void)LoadParticleEffectFiles;
+ (nonnull SKEmitterNode *)BallExplosion;
+ (nonnull SKEmitterNode *)BombBallExplosion;
+ (nonnull SKEmitterNode *)BallSmoke;
+ (nonnull SKEmitterNode *)BombSmoke;
+ (nonnull SKEmitterNode *)BombSpark;

@end
