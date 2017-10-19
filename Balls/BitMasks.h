//
//  BitMasks.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/15/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(uint32_t, BVPhysicsCategory) {
    PhysicsCategoryBall                          = 0x1 << 0,
    PhysicsCategoryBallCollisionEnabler          = 0x1 << 1,
    PhysicsCategoryFlyingObject                  = 0x1 << 2,
    PhysicsCategoryFlyingObjectWithBallCollision = 0x1 << 3,
    PhysicsCategoryBucketLaser                   = 0x1 << 4,
    PhysicsCategoryBucketCap                     = 0x1 << 5,
    PhysicsCategoryBucket                        = 0x1 << 6,
    PhysicsCategoryBucketSensor                  = 0x1 << 7,
    PhysicsCategoryBallDestroyer                 = 0x1 << 8,
};
