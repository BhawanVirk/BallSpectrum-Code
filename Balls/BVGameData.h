//
//  BVGameData.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/8/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BVGameData : NSObject

#pragma mark - Instantiator
+ (nonnull instancetype)sharedGameData;

#pragma mark - Setters
- (void)saveBestScores:(int)bestScores;
- (void)saveCoins:(int)coins;
- (void)addCoins:(int)coins;
- (BOOL)chargeCoinsSuccessfully:(int)coins;
- (void)saveLevel:(int)levelNum data:(nonnull NSDictionary *)data;

#pragma mark - Getters
- (NSInteger)bestScores;
- (NSInteger)totalCoins;
- (NSInteger)missingCoins:(int)levelPrice;
- (nonnull NSDictionary *)dataForLevel:(int)levelNum;

#pragma mark - Level
- (NSInteger)recentLevelNum;
- (void)saveRecentLevelNum:(int)levelNum;

#pragma mark - Game Sound
- (void)enableSound;
- (void)disableSound;
- (BOOL)isSoundOn;

#pragma mark - Ads
- (void)enableAds;
- (void)disableAds;
- (BOOL)shouldDisplayAds;

@end
