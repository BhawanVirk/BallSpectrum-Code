//
//  LevelLoader.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVLevelLoader : SKScene

@property (nonatomic) int levelNum;
@property (nonatomic) int levelGroupNum;

- (nonnull instancetype)initWithLevel:(int)levelNum size:(CGSize)size showGoalIntroducer:(BOOL)showGoalIntroducer presentingFromHomePage:(BOOL)presentingFromHomePage;
- (void)preloadLevel:(int)levelNum;
- (void)presentPreloadedLevel;
@end
