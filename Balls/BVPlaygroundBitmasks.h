//
//  BVPlaygroundBitmasks.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

typedef NS_OPTIONS(uint32_t, BVPlaygroundPhysicsCategory) {
    BVPlaygroundPhysicsCategoryHero              = 0x1 << 0,
    BVPlaygroundPhysicsCategoryGround            = 0x1 << 1,
    BVPlaygroundPhysicsCategorySkyEnd            = 0x1 << 2,
    BVPlaygroundPhysicsCategoryObstacle          = 0x1 << 3,
    BVPlaygroundPhysicsCategoryCoin              = 0x1 << 4,
    BVPlaygroundPhysicsCategoryCellGateway       = 0x1 << 5
};