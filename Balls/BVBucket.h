//
//  BVBucket.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/17/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BVBucketAddon) {
    BVBucketAddonCap,
    BVBucketAddonLaser,
    BVBucketAddonSpears
};

@interface BVBucket : SKSpriteNode

@property (nonatomic) BOOL hasCap;
@property (nonatomic) BOOL laserActive;
@property (nonatomic) int targetHitLabelCount;

+ (nonnull instancetype)bucketColored:(nonnull UIColor *)color withAddons:(nullable NSArray *)addons;

- (void)removeBucketCap;

@end
