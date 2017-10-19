//
//  LevelData.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/25/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BVLevelsData : NSObject

+ (NSDictionary *)dataForLevel:(int)level;
+ (NSUInteger)totalLevels;

#pragma mark - Levels
+ (NSDictionary *)level1;
+ (NSDictionary *)level2;
+ (NSDictionary *)level3;
+ (NSDictionary *)level4;
+ (NSDictionary *)level5;
+ (NSDictionary *)level6;
+ (NSDictionary *)level7;
+ (NSDictionary *)level8;
+ (NSDictionary *)level9;
+ (NSDictionary *)level10;
+ (NSDictionary *)level11;
+ (NSDictionary *)level12;
+ (NSDictionary *)level13;
+ (NSDictionary *)level14;
+ (NSDictionary *)level15;
+ (NSDictionary *)level16;
+ (NSDictionary *)level17;
+ (NSDictionary *)level18;
+ (NSDictionary *)level19;
+ (NSDictionary *)level20;
@end
