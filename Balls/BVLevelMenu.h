//
//  BVLevelMenu.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/21/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class BVHud, BVLevel;

@interface BVLevelMenu : SKSpriteNode

@property (nonatomic, weak) BVLevel *level;
@property (nonatomic, weak) BVHud *bottomHud;

- (void)presentMenu;
- (void)dismissMenu;
- (void)removeAllButtonTargets;

@end
