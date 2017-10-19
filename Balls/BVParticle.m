//
//  BVParticle.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/5/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVParticle.h"

@implementation BVParticle

+ (SKEmitterNode *)loadFile:(NSString *)fileName
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"sks"]];
}

+ (void)LoadParticleEffectFiles
{
    sBallExplosion = [BVParticle loadFile:@"BallExplosion"];
    sBombBallExplosion = [BVParticle loadFile:@"BombBallExplosion"];
    sBallSmoke = [BVParticle loadFile:@"BallSmoke"];
    sBombSmoke = [BVParticle loadFile:@"BombSmoke"];
    sBombSpark = [BVParticle loadFile:@"BombSpark"];
}

static SKEmitterNode *sBallExplosion = nil;
+ (SKEmitterNode *)BallExplosion
{
    return [sBallExplosion copy];
}

static SKEmitterNode *sBombBallExplosion = nil;
+ (SKEmitterNode *)BombBallExplosion
{
    return [sBombBallExplosion copy];
}

static SKEmitterNode *sBallSmoke = nil;
+ (SKEmitterNode *)BallSmoke
{
    return [sBallSmoke copy];
}

static SKEmitterNode *sBombSmoke = nil;
+ (SKEmitterNode *)BombSmoke
{
    return [sBombSmoke copy];
}

static SKEmitterNode *sBombSpark = nil;
+ (SKEmitterNode *)BombSpark
{
    return [sBombSpark copy];
}

@end
