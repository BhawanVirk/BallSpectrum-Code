//
//  BVGameData.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/8/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVGameData.h"
#import "NSUserDefaults+SecureAdditions.h"

@interface BVGameData ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end

@implementation BVGameData

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+ (instancetype)loadInstance
{
    BVGameData *gameDataInstance = [[BVGameData alloc] init];
    gameDataInstance.userDefaults = [NSUserDefaults standardUserDefaults];
    
    return gameDataInstance;
}

#pragma mark - Best Scores

- (void)saveBestScores:(int)bestScores
{
    [_userDefaults setSecretInteger:bestScores forKey:@"bestScores"];
}

- (NSInteger)bestScores
{
    NSInteger bestScores = [_userDefaults secretIntegerForKey:@"bestScores"];
    
    return bestScores;
}

#pragma mark - Coins

- (void)saveCoins:(int)coins
{
    [_userDefaults setSecretInteger:coins forKey:@"totalCoins"];
}

- (void)addCoins:(int)coins
{
    [self saveCoins:((int)[self totalCoins] + coins)];
}

/**
 This method set's new value for coins
 */
- (BOOL)chargeCoinsSuccessfully:(int)coins
{
    int coinsLeft = (int)[self totalCoins] - coins;
    
    if (coinsLeft >= 0) {
        [self saveCoins:coinsLeft];
        return YES;
    }
    
    return NO;
}

- (NSInteger)missingCoins:(int)levelPrice
{
    int missingCoins = (int)[self totalCoins] - levelPrice;
    
    if (missingCoins <= 0) {
        return abs(missingCoins);
    }
    else {
        return 0;
    }
}

- (NSInteger)totalCoins
{
    NSInteger totalCoins = [_userDefaults secretIntegerForKey:@"totalCoins"];
    
    return totalCoins;
}

#pragma mark - Level

- (void)saveLevel:(int)levelNum data:(NSDictionary *)data
{
    NSString *levelKey = [NSString stringWithFormat:@"level%i", levelNum];
    
    /*
    NSDictionary *dataExample = @{@"passed": @YES,
                                  @"pointsEarned": @25000,
                                  @"starsEarned": @3,
                                  @"locked": @NO};
    */
    
    [_userDefaults setSecretObject:data forKey:levelKey];
}

- (NSDictionary *)dataForLevel:(int)levelNum
{
    NSDictionary *levelData = [_userDefaults secretDictionaryForKey:[NSString stringWithFormat:@"level%i", levelNum]];
    
    NSLog(@"levelData: %@", levelData);
    
    if (levelData) {
        return levelData;
    } else {
        return @{@"locked": @YES};
    }
}

- (NSInteger)recentLevelNum
{
    return [_userDefaults secretIntegerForKey:@"xxxxxxxxxxxxxxxxxx"];
}

- (void)saveRecentLevelNum:(int)levelNum
{
    [_userDefaults setSecretInteger:levelNum forKey:@"xxxxxxxxxxxxxxxxxx"];
}

#pragma mark - Game Sound

- (void)enableSound
{
    [_userDefaults setSecretBool:YES forKey:@"gameSound"];
}

- (void)disableSound
{
    [_userDefaults setSecretBool:NO forKey:@"gameSound"];
}

- (BOOL)isSoundOn
{
    return [_userDefaults secretBoolForKey:@"gameSound"];
}

#pragma mark - Ads

- (void)enableAds
{
    [_userDefaults setSecretObject:@"xxxxxxxxxxxxxxxxxx" forKey:@"xxxxxxxxxxxxxxxxxx"];
}

- (void)disableAds
{
    [_userDefaults setSecretObject:@"xxxxxxxxxxxxxxxxxx" forKey:@"xxxxxxxxxxxxxxxxxx"];
}

- (BOOL)shouldDisplayAds
{
    NSString *ads = [_userDefaults secretObjectForKey:@"xxxxxxxxxxxxxxxxxx"];
    
    if ([ads isEqualToString:@"xxxxxxxxxxxxxxxxxx"]) {
        return NO;
    }
    
    return YES;
}

@end
