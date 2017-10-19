//
//  LevelData.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/25/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVLevelsData.h"
#import "BVBucket.h"
#import "BVBall.h"
#import "BVFlyingObject.h"
#import "BVColor.h"

@implementation BVLevelsData

+ (NSDictionary *)dataForLevel:(int)level
{
    NSString *levelMethod = [NSString stringWithFormat:@"level%i", level];
    SEL s = NSSelectorFromString(levelMethod);
    NSDictionary *levelData = (NSDictionary *)[BVLevelsData performSelector:s];
    return levelData;
}

#pragma mark - Utility Methods

+ (NSArray *)generateGoal:(NSArray *)targets
{
    NSMutableArray *goal = [NSMutableArray array];
    for (NSArray *target in targets) {
        
        [goal addObject:[self mutableDictionary:@{@"targetColor": target[0], @"target": target[1], @"hit": target[2]}]];
    }
    
    return [NSArray arrayWithArray:goal];
}

+ (NSMutableDictionary *)mutableDictionary:(NSDictionary *)dictionary
{
    return [NSMutableDictionary dictionaryWithDictionary:dictionary];
}

+ (NSMutableArray *)mutableArray:(NSArray *)array
{
    return [NSMutableArray arrayWithArray:array];
}

+ (NSUInteger)totalLevels
{
    return 20;
}

#pragma mark - DATA

+ (NSDictionary *)level1
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidGreen],
                                                [BVBall solidRed]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor red] withAddons:@[@{@"count": @1}]]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor red], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @1,
                                                        @"starPoints": @[@1500, @3000, @5000]}],
             @"data": [self mutableDictionary:@{@"unlockFor": @0}]
             };
}

+ (NSDictionary *)level2
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidGreen],
                                                [BVBall solidBlue],
                                                [BVBall solidGreen]
                                                ]],
             @"bucketsList": [self mutableArray:@[
                                                  [BVBucket bucketColored:[BVColor green] withAddons:@[@{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor red] withAddons:nil]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor green], @2, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @2,
                                                        @"starPoints": @[@1000, @5500, @10000]}],
             @"data": [self mutableDictionary:@{@"unlockFor": @1500}],
             @"hint": @"Good Luck :)"
             };
}

+ (NSDictionary *)level3
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall solidViolet],
                                                [BVBall solidOrange]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor violet] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor violet], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @2,
                                                        @"starPoints": @[@1500, @3000, @6500]}],
             @"data": [self mutableDictionary:@{@"unlockFor": @2000}],
             @"hint": @"Bomb ball's help destroying pipe blockers"
             };
}

+ (NSDictionary *)level4
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:85 g:51 b:235]],
                                                [BVBall ballColored:[BVColor r:219 g:209 b:32]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:219 g:209 b:32] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:85 g:51 b:235] withAddons:nil]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor r:219 g:209 b:32], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @1,
                                                        @"starPoints": @[@1000, @3000, @5000]}],
             @"data": [self mutableDictionary:@{@"unlockFor": @2500}],
             @"hint": @"Try not to hit the laser"
             };
}

+ (NSDictionary *)level5
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidGreen],
                                                [BVBall solidRed],
                                                [BVBall ballWithMixtureOfColor1:[BVColor violet] andColor2:[BVColor blue]],
                                                [BVBall ballWithMixtureOfColor1:[BVColor yellow] andColor2:[BVColor green]],
                                                [BVBall solidViolet]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor violet] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor green] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor red] withAddons:@[@{@"count": @1}]]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor violet], @1, @0],
                                           @[[BVColor green], @1, @0],
                                           @[[BVColor red], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @3,
                                                        @"starPoints": @[@5000, @10000, @15000],
                                                        @"timer": @8}],
             @"data": [self mutableDictionary:@{@"unlockFor": @3000}],
             @"hint": @"Don't forget the timer"
             };
}

+ (NSDictionary *)level6
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:51 g:224 b:235]],
                                                [BVBall ballColored:[BVColor r:219 g:140 b:32]],
                                                [BVBall solidViolet],
                                                [BVBall ballColored:[BVColor r:51 g:224 b:235]],
                                                [BVBall solidBlue]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:51 g:224 b:235] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor blue] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor r:51 g:224 b:235], @2, @0],
                                           @[[BVColor blue], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @3,
                                                        @"starPoints": @[@10000, @15000, @20000],
                                                        @"timer": @8,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject Points:5000 withCap:NO]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"outToIn"],
                                                                            @"switchRows": @YES,
                                                                            @"scrollingSpeeds": @[@70, @70, @70, @70],
                                                                            @"scrollingDirections": @[@1, @-1, @1, @-1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @6000}],
             @"hint": @"Try not to hit the spikes"
             };
}

+ (NSDictionary *)level7
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidViolet],
                                                [BVBall solidYellow],
                                                [BVBall ballWithMixtureOfColor1:[BVColor violet] andColor2:[BVColor blue]],
                                                [BVBall solidRed],
                                                [BVBall solidBlue],
                                                [BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall ballWithMixtureOfColor1:[BVColor red] andColor2:[BVColor green]],
                                                [BVBall solidGreen],
                                                [BVBall ballWithMixtureOfColor1:[BVColor violet] andColor2:[BVColor red]],
                                                [BVBall solidRed],
                                                [BVBall ballWithType:BVBallTypeBomb]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor green] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor yellow] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor red] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor green], @1, @0],
                                           @[[BVColor yellow], @1, @0],
                                           @[[BVColor red], @2, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @6,
                                                        @"starPoints": @[@10000, @18000, @26500],
                                                        @"timer": @13,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject Points:5000 withCap:YES]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Points:-10000 withCap:NO]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"outToIn"],
                                                                            @"switchRows": @YES,
                                                                            @"scrollingSpeeds": @[@70, @70, @70, @70],
                                                                            @"scrollingDirections": @[@1, @-1, @1, @-1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @6400}],
             @"hint": @"Don't forget those extra points flying around :)"
             };
}

+ (NSDictionary *)level8
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidRed],
                                                [BVBall ballWithMixtureOfColor1:[BVColor green] andColor2:[BVColor yellow]],
                                                [BVBall solidYellow],
                                                [BVBall solidBlue],
                                                [BVBall solidOrange],
                                                [BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall ballWithMixtureOfColor1:[BVColor orange] andColor2:[BVColor green]],
                                                [BVBall solidViolet],
                                                [BVBall ballWithMixtureOfColor1:[BVColor violet] andColor2:[BVColor orange]],
                                                [BVBall solidBlue],
                                                [BVBall ballWithMixtureOfColor1:[BVColor violet] andColor2:[BVColor red]],
                                                [BVBall solidYellow],
                                                [BVBall ballWithType:BVBallTypeBomb]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor orange] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor mixEmUp:@[[BVColor violet], [BVColor red]]] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor violet] withAddons:@[@{@"count": @1}]]
                                                  ]],
             @"goal": [self generateGoal:@[@[[BVColor orange], @1, @0],
                                           @[[BVColor mixEmUp:@[[BVColor violet], [BVColor red]]], @1, @0],
                                           @[[BVColor violet], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @5,
                                                        @"starPoints": @[@5000, @15000, @21500],
                                                        @"timer": @18,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Points:5000 withCap:YES], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Timer:-5 withCap:YES]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@70, @70, @70, @70],
                                                                            @"scrollingDirections": @[@1, @1, @1, @1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @7500}]
             };
}

+ (NSDictionary *)level9
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:255 g:0 b:216]],
                                                [BVBall solidOrange],
                                                [BVBall ballWithMixtureOfColor1:[BVColor blue] andColor2:[BVColor green]],
                                                [BVBall solidYellow],
                                                [BVBall ballWithMixtureOfColor1:[BVColor red] andColor2:[BVColor green]],
                                                [BVBall ballWithMixtureOfColor1:[BVColor yellow] andColor2:[BVColor green]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor yellow] withAddons:@[@{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor mixEmUp:@[[BVColor yellow], [BVColor green]]] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:255 g:0 b:216] withAddons:@[@{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor yellow], @1, @0],
                                           @[[BVColor mixEmUp:@[[BVColor yellow], [BVColor green]]], @1, @0],
                                           @[[BVColor r:255 g:0 b:216], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @4,
                                                        @"starPoints": @[@6300, @12600, @18500],
                                                        @"timer": @12,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject SpikesWithBlinkInterval:0],[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank], [BVFlyingObject Blank]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Points:2000 withCap:NO], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Timer:-15 withCap:NO]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@140, @110, @90, @65],
                                                                            @"scrollingDirections": @[@1, @-1, @1, @-1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @8000}]
             };
}

+ (NSDictionary *)level10
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:204 g:212 b:0]],
                                                [BVBall ballColored:[BVColor r:0 g:164 b:169]],
                                                [BVBall ballColored:[BVColor r:255 g:13 b:78]],
                                                [BVBall solidRed],
                                                [BVBall solidOrange],
                                                [BVBall solidRed],
                                                [BVBall ballColored:[BVColor r:255 g:13 b:78]],
                                                [BVBall ballColored:[BVColor r:111 g:0 b:255]],
                                                [BVBall solidBlue]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:111 g:0 b:255] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:255 g:13 b:78] withAddons:@[@(BVBucketAddonLaser), @{@"count": @3}]],
                                                  [BVBucket bucketColored:[BVColor r:204 g:212 b:0] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:111 g:0 b:255], @1, @0],
                                           @[[BVColor r:255 g:13 b:78], @3, @0],
                                           @[[BVColor r:204 g:212 b:0], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @7,
                                                        @"starPoints": @[@15000, @20000, @26500],
                                                        @"timer": @20,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject Timer:3 withCap:YES], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:2]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:255 g:13 b:78] quantity:1], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[[BVFlyingObject Timer:-5 withCap:NO]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@65, @70, @110, @80],
                                                                            @"scrollingDirections": @[@1, @-1, @-1, @1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @9000}]
             };
}

+ (NSDictionary *)level11
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:242 g:36 b:53]],
                                                [BVBall ballColored:[BVColor r:140 g:153 b:175]],
                                                [BVBall ballColored:[BVColor r:43 g:44 b:66]],
                                                [BVBall ballColored:[BVColor r:220 g:31 b:32]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:242 g:36 b:53] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:43 g:44 b:66] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:140 g:153 b:175] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:242 g:36 b:53], @1, @0],
                                           @[[BVColor r:43 g:44 b:66], @1, @0],
                                           @[[BVColor r:140 g:153 b:175], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @4,
                                                        @"starPoints": @[@10000, @15000, @20000],
                                                        @"timer": @13,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:1.0], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:1.0], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:1.0]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1]],
                                                                                  @[[BVFlyingObject Points:5000 withCap:YES], [BVFlyingObject Blank], [BVFlyingObject Timer:-2 withCap:NO]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:1.0], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:1.0], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:1.0]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@70, @70, @80, @80],
                                                                            @"scrollingDirections": @[@1, @-1, @1, @-1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @11000}]
             };
}

+ (NSDictionary *)level12
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:254 g:233 b:57]],
                                                [BVBall ballColored:[BVColor r:86 g:191 b:238]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:86 g:191 b:238] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:254 g:233 b:57] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:154 g:199 b:47] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:86 g:191 b:238], @1, @0],
                                           @[[BVColor r:254 g:233 b:57], @1, @0],
                                           @[[BVColor r:154 g:199 b:47], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @4,
                                                        @"starPoints": @[@10000, @15000, @20000],
                                                        @"timer": @20,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:154 g:199 b:47] quantity:1]],
                                                                                  @[[BVFlyingObject Points:5000 withCap:YES], [BVFlyingObject Blank], [BVFlyingObject Timer:-4 withCap:NO]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:2.5 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:0.5 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:2.5 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:0.5 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:2.5 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:0.5 startRandomly:YES]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@70, @70, @80, @0],
                                                                            @"scrollingDirections": @[@1, @-1, @1, @-1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @12900}]
             };
}

+ (NSDictionary *)level13
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidOrange]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor blue] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor orange] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor blue], @1, @0],
                                           @[[BVColor orange], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @4,
                                                        @"starPoints": @[@5000, @10000, @15000],
                                                        @"timer": @9,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Points:5000 withCap:YES], [BVFlyingObject Blank], [BVFlyingObject RowSpeedIncreaseBy:2], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor blue] quantity:1]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@141, @70, @70, @100],
                                                                            @"scrollingDirections": @[@1, @1, @-1, @1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @14000}]
             };
}

+ (NSDictionary *)level14
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:71 g:77 b:75]],
                                                [BVBall ballColored:[BVColor r:224 g:248 b:0]],
                                                [BVBall ballColored:[BVColor r:71 g:77 b:75]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:248 g:59 b:150] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:224 g:248 b:0] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:71 g:77 b:75] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:248 g:59 b:150], @1, @0],
                                           @[[BVColor r:224 g:248 b:0], @1, @0],
                                           @[[BVColor r:71 g:77 b:75], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @5,
                                                        @"starPoints": @[@5000, @10000, @16500],
                                                        @"timer": @20,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject Blank],[BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0],[BVFlyingObject RowSpeedDecreaseBy:2]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:2]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:248 g:59 b:150] quantity:1]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@250, @70, @70, @100],
                                                                            @"scrollingDirections": @[@1, @-1, @1, @1]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @15000}]
             };
}

+ (NSDictionary *)level15
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:71 g:77 b:75]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:45 g:177 b:135] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:43 g:190 b:207] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:45 g:177 b:135], @2, @0],
                                           @[[BVColor r:43 g:190 b:207], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @5,
                                                        @"starPoints": @[@5000, @10000, @16500],
                                                        @"timer": @15,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@3, @"r":@0}]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@1, @"r":@1}]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:45 g:177 b:135] quantity:2 flyOptions:@{@"l":@1, @"r":@1}], [BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:43 g:190 b:207] quantity:1 flyOptions:@{@"l":@0, @"r":@2}]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1 flyOptions:@{@"l":@1, @"r":@2, @"speedBy": @-3}], [BVFlyingObject Blank],[BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@1, @"r":@2}]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@70, @70, @150, @200],
                                                                            @"scrollingDirections": @[@1, @-1, @-1, @-1],
                                                                            @"backAndForthRow": @[@YES, @YES, @YES, @YES]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @17900}]
             };
}

+ (NSDictionary *)level16
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:44 g:135 b:0]],
                                                [BVBall ballColored:[BVColor r:44 g:135 b:0]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:220 g:217 b:44] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:44 g:135 b:0] withAddons:@[@(BVBucketAddonLaser), @{@"count": @3}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:220 g:217 b:44], @2, @0],
                                           @[[BVColor r:44 g:135 b:0], @3, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @6,
                                                        @"starPoints": @[@10000, @20000, @25000],
                                                        @"timer": @30,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@0, @"r":@3}]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:1 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:1 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:1 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:1 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:1 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:1 startRandomly:YES]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:44 g:135 b:0] quantity:2 flyOptions:@{@"l":@6, @"r":@0}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"r":@3, @"l":@0, @"speedBy": @1.5}]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:220 g:217 b:44] quantity:2 flyOptions:@{@"r":@2, @"l":@1}], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:44 g:135 b:0] quantity:1 flyOptions:@{@"l":@2, @"r":@1}]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@70, @0, @150, @200],
                                                                            @"scrollingDirections": @[@-1, @-1, @-1, @-1],
                                                                            @"backAndForthRow": @[@YES, @NO, @YES, @YES]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @18800}]
             };
}

+ (NSDictionary *)level17
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall solidRed],
                                                [BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall ballColored:[BVColor r:255 g:44 b:81]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:254 g:239 b:79] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:255 g:44 b:81] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:31 g:173 b:255] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:254 g:239 b:79], @1, @0],
                                           @[[BVColor r:255 g:44 b:81], @2, @0],
                                           @[[BVColor r:31 g:173 b:255], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @5,
                                                        @"starPoints": @[@10000, @20000, @28000],
                                                        @"timer": @30,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0 startRandomly:YES flyOptions:@{@"r":@3, @"l":@0}]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:4 startRandomly:YES], [BVFlyingObject SpikesWithBlinkInterval:0 startRandomly:YES flyOptions:@{@"l":@3, @"r":@0}], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:4 startRandomly:YES]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:255 g:44 b:81] quantity:1], [BVFlyingObject Blank], [BVFlyingObject Timer:-5 withCap:NO], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:31 g:173 b:255] quantity:1], [BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:254 g:239 b:79] quantity:1], [BVFlyingObject Points:8000 withCap:YES]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"r":@2}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"r":@2}], [BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@2}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@2}]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@130, @130, @70, @100],
                                                                            @"scrollingDirections": @[@-1, @1, @-1, @1],
                                                                            @"backAndForthRow": @[@YES, @YES, @NO, @YES]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @20000}]
             };
}

+ (NSDictionary *)level18
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:221 g:221 b:155]],
                                                [BVBall ballColored:[BVColor r:202 g:38 b:138]],
                                                [BVBall ballColored:[BVColor r:30 g:38 b:80]],
                                                [BVBall ballColored:[BVColor r:221 g:221 b:155]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:202 g:38 b:138] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:30 g:38 b:80] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:221 g:221 b:155] withAddons:@[]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:202 g:38 b:138], @1, @0],
                                           @[[BVColor r:30 g:38 b:80], @2, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @6,
                                                        @"starPoints": @[@10000, @15000, @23000],
                                                        @"timer": @25,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@1, @"r":@1}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@1, @"r":@1}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@1, @"r":@1}], [BVFlyingObject Blank],[BVFlyingObject RightAngleStopWithRightSlope:NO]],
                                                                                  @[[BVFlyingObject RightAngleStopWithRightSlope:NO]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:30 g:38 b:80] quantity:1]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeBomb color:nil quantity:1 flyOptions:@{@"r":@1, @"l":@5}], [BVFlyingObject Blank], [BVFlyingObject Points:8000 withCap:YES]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@90, @90, @90, @120],
                                                                            @"scrollingDirections": @[@-1, @1, @-1, @-1],
                                                                            @"backAndForthRow": @[@YES, @NO, @NO, @YES]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @22000}]
             };
}

+ (NSDictionary *)level19
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall ballColored:[BVColor r:9 g:199 b:122]],
                                                [BVBall ballColored:[BVColor r:0 g:194 b:185]]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:0 g:121 b:232] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:9 g:199 b:122] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:0 g:194 b:185] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:0 g:121 b:232], @2, @0],
                                           @[[BVColor r:9 g:199 b:122], @1, @0],
                                           @[[BVColor r:0 g:194 b:185], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @5,
                                                        @"starPoints": @[@10000, @15000, @21500],
                                                        @"timer": @30,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:5 startRandomly:NO], [BVFlyingObject SpikesWithBlinkInterval:5 startRandomly:NO]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"r":@3}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"r":@3}]],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject RightAngleStopWithRightSlope:NO blinkingInt:1.0 startRandomly:NO]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@2}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@2}], [BVFlyingObject SpikesWithBlinkInterval:0 flyOptions:@{@"l":@2}], [BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:0 g:121 b:232] quantity:2 flyOptions:@{@"r":@2}]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@0, @180, @90, @90],
                                                                            @"scrollingDirections": @[@-1, @-1, @1, @-1],
                                                                            @"backAndForthRow": @[@NO, @YES, @YES, @YES]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @25000}]
             };
}

+ (NSDictionary *)level20
{
    return @{
             @"ballsList": [self mutableArray:@[[BVBall ballColored:[BVColor r:135 g:146 b:157]],
                                                [BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall solidRed],
                                                [BVBall ballWithType:BVBallTypeBomb],
                                                [BVBall ballColored:[BVColor r:0 g:0 b:0]],
                                                [BVBall ballWithType:BVBallTypeBomb]
                                                ]],
             @"bucketsList": [self mutableArray:@[[BVBucket bucketColored:[BVColor r:175 g:186 b:197] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:135 g:146 b:157] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:101 g:112 b:123] withAddons:@[@(BVBucketAddonLaser), @{@"count": @2}]],
                                                  [BVBucket bucketColored:[BVColor r:60 g:68 b:75] withAddons:@[@(BVBucketAddonCap), @{@"count": @1}]],
                                                  [BVBucket bucketColored:[BVColor r:0 g:0 b:0] withAddons:@[@(BVBucketAddonLaser), @{@"count": @1}]]]],
             @"goal": [self generateGoal:@[@[[BVColor r:175 g:186 b:197], @2, @0],
                                           @[[BVColor r:135 g:146 b:157], @1, @0],
                                           @[[BVColor r:101 g:112 b:123], @2, @0],
                                           @[[BVColor r:60 g:68 b:75], @1, @0],
                                           @[[BVColor r:0 g:0 b:0], @1, @0]
                                           ]],
             @"goal-options": [self mutableDictionary:@{@"moves": @10,
                                                        @"starPoints": @[@25000, @38000, @48000],
                                                        @"timer": @90,
                                                        @"flyingObjects": @{@"objects":
                                                                                @[@[[BVFlyingObject Blank], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[],
                                                                                  @[[BVFlyingObject Blank], [BVFlyingObject Blank], [BVFlyingObject RightAngleStopWithRightSlope:NO flyOptions:@{@"r":@2}]],
                                                                                  @[[BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:1], [BVFlyingObject SpikesWithBlinkInterval:1], [BVFlyingObject SpikesWithBlinkInterval:1], [BVFlyingObject SpikesWithBlinkInterval:0], [BVFlyingObject SpikesWithBlinkInterval:0]],
                                                                                  @[[BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:175 g:186 b:197] quantity:2], [BVFlyingObject Blank], [BVFlyingObject Timer:-20 withCap:NO], [BVFlyingObject Points:10000 withCap:YES], [BVFlyingObject Blank], [BVFlyingObject GiveBallType:BVBallTypeColored color:[BVColor r:101 g:112 b:123] quantity:2], [BVFlyingObject Blank]]
                                                                                  ],
                                                                            @"rolling": @[@YES, @"inToOut"],
                                                                            @"switchRows": @NO,
                                                                            @"scrollingSpeeds": @[@0, @0, @150, @90, @90],
                                                                            @"scrollingDirections": @[@-1, @1, @1, @-1, @-1],
                                                                            @"backAndForthRow": @[@NO, @NO, @YES, @YES, @NO]
                                                                            }}],
             @"data": [self mutableDictionary:@{@"unlockFor": @35000}]
             };
}
@end
