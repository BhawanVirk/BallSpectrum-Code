//
//  Level.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

@import GoogleMobileAds;
@import GameKit;

#import "BVLevel.h"
#import "BVLevelLoader.h"
#import "BVLevelsData.h"
#import "BVRackGenerator.h"
#import "UIColor+Mix.h"
#import "BVColor.h"
#import "BVLabelNode.h"
#import "KLCPopup.h"
#import "UIImage+Scaling.h"
#import "BVSize.h"
#import "BitMasks.h"
#import "SKSpriteNode+BVPos.h"
#import "BVTransition.h"
#import "BVLevelSummary.h"
#import "BVParticle.h"
#import "BVUtility.h"
#import "AGSpriteButton.h"
#import "BVGameData.h"
#import "BVButton.h"
#import "PlayLevelViewController.h"
#import "GuideViewController.h"
#import "BVAds.h"
#import "BVSounds.h"

#import "MainViewController.h"
#import "LevelsViewController.h"

#define radians(degrees) (degrees * M_PI/180)

@implementation BVLevel
{
    BVAds *_ads;
    SKSpriteNode *_ballCollisionEnabler;
    AGSpriteButton *_replayLevelButton;
    AGSpriteButton *_levelsButton;
    BOOL _goalHit;
    BOOL _mixingColors;
    BOOL _gameWillEnd;
    BOOL _gameEnded;
    BOOL _presentingFromHomePage;
    int _moves;
    int _possibleNumOfBallsThatCanHitDestroyer;
    int _numOfBallsThatHitDestroyer;
    int _pointsTarget;
    int _levelNum;
    CGSize _screenSize;
    NSString *_lvlHint;
    NSArray *_goalTargets;
    NSDictionary *_goalOptions;
}

#pragma mark - Initializer

- (nonnull instancetype)initWithLevel:(int)level showGoalIntroducer:(BOOL)showGoalIntroducer presentingFromHomePage:(BOOL)presentingFromHomePage
{
    self = [super init];
    
    if (self) {
        
        // Add observer for notifications, which we'll receive everytime ball gets released from hanger
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ballReleased:) name:@"BVBallGotReleased" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBallsAddedSuccessfully:) name:@"NewBallsAddedSuccessfully" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guideViewControllerGotDismissed) name:@"GuideViewControllerDismissed" object:nil];
        
        _screenSize = [BVSize originalScreenSize];
        _levelNum = level;
        _presentingFromHomePage = presentingFromHomePage;
        _rollingThings = [[BVRollingThings alloc] init];
        _rollingThings.parentNode = self;
        
        // setup ads
        if ([[BVGameData sharedGameData] shouldDisplayAds]) {
            _ads = [[BVAds alloc] initWithReachability:NO]; // reachability is off because it causes errors here. (weird)
            _ads.noInterstitialAdForThisManyTimes = 2;
            _ads.levelNode = self;
        }
        
        //self.texture = [SKTexture textureWithImageNamed:@"level-background"];
        self.color = [BVColor r:137 g:226 b:255];
        
        // setup clouds
        [_rollingThings addClouds];
        
        // add trees background
        SKSpriteNode *trees = [_rollingThings grass];
        trees.position = CGPointMake(0, -(_screenSize.height / 2)+ (trees.size.height/2));
        trees.zPosition = 1;
        [self addChild:trees];
        
        NSDictionary *levelData = [BVLevelsData dataForLevel:level];
        NSArray *ballsList = [levelData objectForKey:@"ballsList"];
        NSArray *bucketsList = [levelData objectForKey:@"bucketsList"];
        _goalTargets = [levelData objectForKey:@"goal"];
        
//        // TODO: remove this code
//#warning Remove this code after finish working with game center achievements
//        int i = 1;
//        for (BVBall *ball in ballsList) {
//            
//            CGColorRef cgColor = ball.color.CGColor;
//            const CGFloat *colorComponents = CGColorGetComponents(cgColor);
//            
//            NSLog(@"color %i: r=%f, g=%f, b=%f", i, colorComponents[0]*255, colorComponents[1]*255, colorComponents[2]*255);
//            
//            i++;
//        }
        
        // goal options
        _goalOptions = [levelData objectForKey:@"goal-options"];
        _lvlHint = [levelData objectForKey:@"hint"];
        _moves = [[_goalOptions objectForKey:@"moves"] intValue];
        _pointsTarget = [[[_goalOptions objectForKey:@"starPoints"] lastObject] intValue];
        
        // track number of balls that have hitted the destroyer and how many can.
        // as this is just start, so val will be 0
        _possibleNumOfBallsThatCanHitDestroyer = _moves;
        _numOfBallsThatHitDestroyer = 0;
        
        // add top hud
        _hudTop = [BVHud topHudOfLevel:level wthTargets:_goalTargets viewSize:_screenSize];
        _hudTop.name = @"hud-top";
        _hudTop.zPosition = 4.0;
        [self addChild:_hudTop];
        
        // setup balls rack
        _ballsRack = [[BVRackGenerator alloc] initWithBalls:ballsList];
        //_ballsRack.size = [_ballsRack calculateAccumulatedFrame].size;
        [_ballsRack setPosRelativeTo:_hudTop.frame side:BVPosSideBottom margin:5];
        
        NSDictionary *flyingObjectsInfo = [_goalOptions objectForKey:@"flyingObjects"];
        
        if (flyingObjectsInfo != nil) {
            [self addFlyingObjectsToLevel:flyingObjectsInfo];
        }
        
        // add ball collision enabler
        [self addBallCollisionEnabler];
        // position it just after the balls rack with an offset of ball's height
        float ballHeight = [BVBall clearBall].size.height;
        float collisionEnablerMargin = [BVSize valueOniPhones:(ballHeight / 2) andiPads:(ballHeight / 4)];
        [_ballCollisionEnabler setPosRelativeTo:_ballsRack.frame side:BVPosSideBottom margin:collisionEnablerMargin];
        
        // add bottom hud
        _hudBottom = [BVHud bottomHudOfLevel:level withGoalOptions:_goalOptions viewSize:_screenSize];
        _hudBottom.name = @"hud-bottom";
        _hudBottom.zPosition = 6.0;
        [self addChild:_hudBottom];
    
        // Setup bucket handler
        _bucketsRack = [[BVRackGenerator alloc] initWithBuckets:bucketsList bottomMargin:_hudBottom.size.height];
        
        // make bucket's rack scrolling available on _hudBottom touches
        _hudBottom.enableBucketRackScrollingOnTouch = !_bucketsRack.isScrollingPaused;
        _hudBottom.bucketRack = _bucketsRack;
        
        // Add nodes
        [self addChild:_ballsRack];
        [self addChild:_bucketsRack];
        
        // Add menu
        _menu = [[BVLevelMenu alloc] init];
        _menu.position = CGPointZero;
        _menu.level = self;
        _menu.bottomHud = _hudBottom;
        [self addChild:_menu];
        
        // Note: showLevelIntroducerPopup will automatically enable level timer after dismissing the popup
        if (showGoalIntroducer) {
            // add level's goal introducer popup
            [self showLevelIntroducerPopup];
            
            // hide elements to run animation when user dismiss goal introducer popup
            _hudTop.alpha = 0.0;
            _ballsRack.alpha = 0.0;
            _flyingObjectsCanvas.alpha = 0.0;
            _bucketsRack.alpha = 0.0;
            _hudBottom.alpha = 0.0;
        }
        else {
            // enable the goal timer if any required by level
            _hudBottom.timerPaused = NO;
        }
        
        self.userInteractionEnabled = YES;

    }
    
    return self;
}

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - Logic

- (void)sensorOfBucket:(BVBucket *)bucket gotHitByBall:(BVBall *)ball
{
    // play ball dropping sound
    [self runAction:[BVSounds ballDropInBucket]];
    
    _mixingColors = YES;
    // Type of points we need to give user. (value will change based on result)
    BVLevelRatingPointsType pointsType = BVLevelRatingPointsTypeNewBucket;
    // before anything, we must mix ball into bucket
    [self mixBallColor:ball intoBucket:bucket];
    
    // (1) do the calculations
    
    // This bucketColor is produced after mixing ball's color in bucket's color
    UIColor *bucketColor = [bucket.userData objectForKey:@"bucketColor"];
    
    if ([BVColor doTheseTwoColorsMatch:@[bucketColor, ball.color]]) {
        pointsType = BVLevelRatingPointsTypeNone;
        
        for (NSDictionary *goalTarget in _goalTargets) {
            UIColor *goalTargetColor = [goalTarget objectForKey:@"targetColor"];
            
            // check if bucket color match with goalTargetColor
            // we don't need to also match goalTargetColor with ball's color, since ball's color is equal to bucket's color
            if ([BVColor doTheseTwoColorsMatch:@[goalTargetColor, bucketColor]]) {
                int currentHits = [[goalTarget valueForKey:@"hit"] intValue];
                int targetHits = [[goalTarget valueForKey:@"target"] intValue];
                
                // reward user point's for hitting the targeted bucket
                if (currentHits < targetHits) {
                    // now increment the hit count of target bucket
                    [goalTarget setValue:@(currentHits + 1) forKey:@"hit"];
                    pointsType = BVLevelRatingPointsTypeTargetBucket;
                    
                    // play target bucket hit sound
                    [self runAction:[BVSounds targetBucketHit]];
                }
                
                bucket.targetHitLabelCount--;
            }
        }
    }
    else {
        // now that bucket color didn't match with ball, so lets reset it's targetHitCountLabel
        bucket.targetHitLabelCount = -1;
    }
    
    // (2) save progress (!)
    
    // (3) update the hud
    
    [self hudAddPoints:pointsType withLabelOverBucket:bucket];
    [_hudTop updateTargetLabels:_goalTargets];
    
    // sensor also works as a ball destroyer, so explicitly call ballHitDestroyer
    [self ballHitDestroyer:ball];
}

- (void)newBallsAddedSuccessfully:(NSNotification *)notification
{
    // now ball holders have finished animating, it's time to check if game needs to end or not.
    [self endGameIfNeedTo];
}

- (void)ballHitDestroyer:(BVBall *)ball
{
    ball.countOfDestroyerHits += 1;
//    NSLog(@"ballHitDestroyer Called!");
//    NSLog(@"ball.countOfDestroyerHits = %i", ball.countOfDestroyerHits);
    
    if (ball.countOfDestroyerHits <= 1) {
//        NSLog(@"ballHitDestroyer Processing The Hit");
        // increment hit count
        _numOfBallsThatHitDestroyer++;
        [_ballsRack removeThisBallFromRack:ball];
        
        if (!_ballsRack.ballsHolderGoingToAnimate && !_ballsRack.ballHoldersAnimating) {
            [self endGameIfNeedTo];
        }
    }
}

- (BOOL)allReleasedBallsHadHittedDestroyer
{
    if (_possibleNumOfBallsThatCanHitDestroyer == _numOfBallsThatHitDestroyer) {
        return YES;
    }
    return NO;
}

/**
 Ball got released, this is the best time to remove one move from _moves.
 */
- (void)ballReleased:(NSNotification *)notification
{
//    NSLog(@"BALL RELEASED YO!: %@", notification.object);
    
    BVBall *ball = (BVBall *)notification.object;
    ball.inAir = YES;
    
//    CGPoint ballHolderPos = [_ballsRack ballHolderPositionOfBall:ball];
//    NSLog(@"BALL HOLDER POS: x=%f, y=%f", ballHolderPos.x, ballHolderPos.y);

    // reset stored value
    _mixingColors = NO;
    
    // decrement the _moves by 1
    [self blowOneMoveAway];
    
    // update move count in bottom hud
    [_hudBottom updateMoves:_moves];
    
    if (![self movesAvailable]) {
        [self stopTouchesExcludingBucketRack];
    }
}

/**
 This method both checks if there are moves available and new match is possible.
 */
- (BOOL)matchIsPossible
{
    if ([self movesAvailable] && ![self allReleasedBallsHadHittedDestroyer]) {
        
        // no match will be possible if there's no ball in the rack
        if (![_ballsRack zeroBallsInRack]) {
            
                for (NSDictionary *target in _goalTargets) {
                    
                    // store bucket info
                    UIColor *targetBucketColor = [target objectForKey:@"targetColor"];
                    int targetToHit = [[target objectForKey:@"target"] intValue];
                    int hitSoFar = [[target objectForKey:@"hit"] intValue];
                    
                    if (targetToHit > hitSoFar) {
                        
                        BOOL targetMatchPossible = NO;
                        BOOL bombBallAvailable = NO;
                        
                        // go through balls list
                        for (BVBall *ball in _ballsRack.ballsList) {
                            if ([BVColor doTheseTwoColorsMatch:@[ball.color, targetBucketColor]]) {
                                targetMatchPossible = YES;
                            }
                            
                            if (ball.type == BVBallTypeBomb) {
                                bombBallAvailable = YES;
                            }
                        }
                        
                        // go through active flying objects list
                        for (BVFlyingObject *ballGiverObject in _flyingObjectsCanvas.activeBallGiverFlyingObjects) {
                            if (ballGiverObject.givesBallOfType == BVBallTypeColored) {
                                if ([BVColor doTheseTwoColorsMatch:@[ballGiverObject.color, targetBucketColor]]) {
                                    targetMatchPossible = YES;
                                }
                            }
                            else if (ballGiverObject.givesBallOfType == BVBallTypeBomb) {
                                bombBallAvailable = YES;
                            }
                        }
                        
                        // Final Check & last chance to say no match possible, even though targetMatchPossible = YES
                        if (targetMatchPossible) {
                            // check if target bucket got cap on it
                            for (BVBucket *bucket in _bucketsRack.bucketsList) {
                                UIColor *bucketColor = [bucket.userData objectForKey:@"bucketColor"];
                                if ([BVColor doTheseTwoColorsMatch:@[bucketColor, targetBucketColor]]) {
                                    if (bucket.hasCap && !bombBallAvailable) {
                                        // what's the point of continuing the game, if we have
                                        // bucket with cap on it and we don't have bomb ball in the
                                        // rack or bomb giver object.
                                        // SO, MATCH IS NOT POSSIBLE
                                        return NO;
                                    }
                                }
                            }
                            
                            return YES;
                        }
                    }
                    
                } // end of for loop
            
        } // end of zerBallsInRack check
        
    }
    
    return NO;
}

- (BOOL)movesAvailable
{
    if (_moves != -1 && _moves == 0) {
        return NO;
    }
    
    return YES;
}

- (void)blowOneMoveAway
{
    // decrement the move
    if (_moves > 0 && _moves != -1) {
        _moves--;
    }
}

- (BOOL)didWon
{
    NSUInteger totalTargets = [_goalTargets count];
    NSUInteger reachedTargets = 0;
    for (NSDictionary *target in _goalTargets) {
        NSNumber *targetNum = [target objectForKey:@"target"];
        NSNumber *hitCount = [target objectForKey:@"hit"];
        if ([targetNum isEqualToNumber:hitCount]) {
            reachedTargets++;
        }
    }
    
    if (totalTargets == reachedTargets) {
        return YES;
    }
    
    return NO;
}

#pragma mark - General

- (void)pauseGame
{
    // stop the timer
    _hudBottom.timerPaused = YES;
    // pause the scene
    self.scene.paused = YES;
}

- (void)resumeGame
{
    // resume the scene
    self.scene.paused = NO;
    // resume the timer
    _hudBottom.timerPaused = NO;
}

#pragma mark - End Game

- (void)endGameIfNeedTo
{
    __weak BVLevel *weakSelf = self;
    // if there is no more possibility of a match,
    // then end the game right away.
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Background Thread
        BOOL matchPossible = [weakSelf matchIsPossible];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!matchPossible && !weakSelf.ballsRack.ballsHolderGoingToAnimate && !weakSelf.ballsRack.ballHoldersAnimating) {
                // end the game if it's still on
                if (!_gameWillEnd) {
                    if (_mixingColors) {
                        // stop any further touches as we're going to end the game as mixing animation ends
                        [weakSelf stopAllTouches];
                        
                        // let the color mixing animation complete before ending the game.
                        //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(endGame) userInfo:nil repeats:NO];
                        
                        NSString *arg1 = nil;
                        
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[weakSelf methodSignatureForSelector:@selector(endGameWithReason:)]];
                        invocation.target = weakSelf;
                        invocation.selector = @selector(endGameWithReason:);
                        [invocation setArgument:&arg1 atIndex:2];
                        
                        [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
                    }
                    else {
                        [weakSelf endGameWithReason:nil];
                    }
                    
                    // save game end state so that we can't call the above code multiple times.
                    _gameWillEnd = YES;
                }
            }
        });
    });
}

- (void)endGameWithReason:(NSString *)reason
{
    [self endGameWithReason:reason lostConfirmed:NO];
}

- (void)endGameWithReason:(NSString *)reason lostConfirmed:(BOOL)lostConfirmed
{
    if (!_gameEnded) {
        // save game end state so that we can't end the game multiple times.
        _gameEnded = YES;
        
        BOOL won = (lostConfirmed) ? NO : [self didWon];
        
        if (!reason) {
            // Find out a reason of ending the level, and then let user know.
            if (won) {
                reason = @"Congratulations! You have finished the level.";
            }
            else {
                if (!_moves) {
                    reason = @"Oops! No more moves left.";
                }
                else {
                    reason = @"No more possible moves left!";
                }
            }
        }
        
        
//        // LOGGING PURPOSES ONLY
//        NSLog(@"Ending Reason: %@", reason);
//        NSLog(@"TOTAL # OF STARS UNLOCKED: %i", _hudBottom.levelRating.numOfStarsEarned);
//        NSLog(@"TOTAL POINTS: %i / %i", _hudBottom.levelRating.pointsEarned, _pointsTarget);
        
        if (!won) {
            [self stopLevelWithReason:reason];
        }
        else {
            // User have won this level
            
            // play level passed sound
            [self runAction:[BVSounds levelPassed]];
            
            int starsEarned = _hudBottom.levelRating.numOfStarsEarned;
            // save level data
            [[BVGameData sharedGameData] saveLevel:_levelNum data:@{@"passed": @YES,
                                                                    @"pointsEarned": @(_hudBottom.levelRating.pointsEarned),
                                                                    @"starsEarned": @(starsEarned),
                                                                    @"locked": @NO}];
            
            // unlock next level if locked
            int nextLevelNum = _levelNum + 1;
            NSDictionary *nextLevelData = [[BVGameData sharedGameData] dataForLevel:nextLevelNum];
            BOOL nextLevelLocked = [[nextLevelData objectForKey:@"locked"] boolValue];
            
            if (nextLevelLocked || nextLevelData == nil) {
                [[BVGameData sharedGameData] saveLevel:(_levelNum + 1) data:@{@"passed": @NO,
                                                                              @"pointsEarned": @0,
                                                                              @"starsEarned": @0,
                                                                              @"locked": @NO}];
            }
            
            NSLog(@"recent level num: %li", (long)[[BVGameData sharedGameData] recentLevelNum]);
            
            // update recent level num if need to
            if (nextLevelNum > [[BVGameData sharedGameData] recentLevelNum]) {
                [[BVGameData sharedGameData] saveRecentLevelNum:nextLevelNum];
            }
            
            /* Game Center Achievements Code */
            if ([GKLocalPlayer localPlayer].authenticated) {
                float currentPercent = ((float)starsEarned / (float)3) * 100;
                GKAchievement *thisLevelAchievement = [[GKAchievement alloc] initWithIdentifier:[NSString stringWithFormat:@"level_%i", _levelNum]];
                thisLevelAchievement.percentComplete = currentPercent;
                thisLevelAchievement.showsCompletionBanner = YES;
                [GKAchievement reportAchievements:@[thisLevelAchievement] withCompletionHandler:nil];
            }
            
            
            UIView *levelEndingReason = [self levelEndingReason:reason didWon:YES];
            
            // pop out all the balls
            for (BVBall *ball in _ballsRack.ballsList) {
                if (ball.type != BVBallTypeClear) {
                    SKEmitterNode *ballPop = [BVParticle BallSmoke];
                    ballPop.particleColor = ball.color;
                    ballPop.particleColorBlendFactor = 1.0;
                    ballPop.particleColorSequence = nil;
                    
                    CGPoint ballPosInRack = [_ballsRack ballPosInRack:ball];
                    CGPoint ballPosInLevel = [_ballsRack convertPoint:ballPosInRack toNode:self];
                    
                    ballPop.position = ballPosInLevel;
                    
                    [BVUtility cleanUpChildrenAndRemove:ball];
                    
                    [self addChild:ballPop];
                }
            }
            
            // empty out ballsList
            //[_ballsRack.ballsList removeAllObjects];
            
            // clear references
            [self clearAllConnections];
            
            __weak BVLevel *weakSelf = self;
            // then move content out of screen
            [self moveContentOutWithCompletion:^{
                KLCPopup *popup = [KLCPopup popupWithContentView:levelEndingReason showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToTop maskType:KLCPopupMaskTypeClear dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
                popup.didFinishDismissingCompletion = ^(){
                    [weakSelf moveToLevelSummaryPage];
                };
                [popup showWithDuration:1.0];
            }];
            
//            NSLog(@"Game End!");
        }
    }
}

#pragma mark - Transition Helpers

- (void)restartLevel
{
    if (!_interstitialAdPresented) {
        for (BVBall *ball in _ballsRack.ballsList) {
            [BVUtility cleanUpChildrenAndRemove:ball];
        }
        
        // empty out ballsList
        [_ballsRack.ballsList removeAllObjects];
        
        // clear references
        [self clearAllConnections];
        
        BVLevelLoader *level = [[BVLevelLoader alloc] initWithLevel:_levelNum size:[BVSize originalScreenSize] showGoalIntroducer:NO presentingFromHomePage:_presentingFromHomePage];
        BVTransition *transition = [[BVTransition alloc] init];
        [transition presentNewScene:level oldScene:self.scene waitingText:@"Refreshing" block:^{}];
    }
}

- (void)moveToLevelSummaryPage
{
    BOOL didWon = [self didWon];
    NSArray *goalTargets = [NSArray arrayWithArray:_goalTargets];
    
    NSDictionary *summaryData = @{@"pointsEarnedAndTarget": @[@(_hudBottom.levelRating.pointsEarned), @(_pointsTarget)],
                                  @"didWon": @(didWon),
                                  @"starsEarned": @(_hudBottom.levelRating.numOfStarsEarned),
                                  @"goalTargets": goalTargets
                                  };
    
    BVLevelSummary *levelSummary = [[BVLevelSummary alloc] initWithSummary:summaryData ofLevel:_levelNum presentingFromHomePage:_presentingFromHomePage];
    
    // transition to level summary page
    BVTransition *transitioner = [[BVTransition alloc] init];
    [transitioner presentNewScene:levelSummary oldScene:self.scene block:^{}];
}

- (void)removeAllButtonTargets
{
    [_replayLevelButton removeAllTargets];
    [_levelsButton removeAllTargets];
    
    [BVUtility cleanUpChildrenAndRemove:_replayLevelButton];
    [BVUtility cleanUpChildrenAndRemove:_levelsButton];
    
    _replayLevelButton = nil;
    _levelsButton = nil;
}

- (void)clearReferences
{
    // remove button references
    [_hudTop removeButtonTargets];
    [_menu removeAllButtonTargets];
    [self removeAllButtonTargets];
    
    // remove other references
    _flyingObjectsCanvas.level = nil;
    _menu.level = nil;
    _menu.bottomHud = nil;
    _hudBottom.bucketRack = nil;
}

- (void)clearAllConnections
{
    // clear references
    [self clearReferences];
    
    [BVUtility cleanUpChildrenAndRemove:_flyingObjectsCanvas];
}

- (UINavigationController *)clearUpAndGiveNavController
{
    // clear references
    [self clearAllConnections];
    
    // get navigation controller reference
    UINavigationController *navController = (UINavigationController *)self.scene.view.window.rootViewController;
    
    [self updatePresentingLevelViewControllersProp];
    
    return navController;
}

- (void)goToLevelsPage
{
    // navigate to levels page
    UINavigationController *navController = [self clearUpAndGiveNavController];
    
    if (!_presentingFromHomePage) {
        // we can just pop the current view controller because the previous one is LevelsViewController
        [navController popViewControllerAnimated:YES];
    }
    else {
        // now we gonna change the eniter stack of viewControllers to correctly present the LevelsViewController
        MainViewController *mainViewController = [navController.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        LevelsViewController *levelsViewController = [navController.storyboard instantiateViewControllerWithIdentifier:@"LevelsViewController"];
        
        [navController setViewControllers:@[mainViewController, levelsViewController] animated:YES];
    }
}

- (void)goToHomepage
{
    // navigate to home page
    UINavigationController *navController = [self clearUpAndGiveNavController];
//    NSLog(@"before view controllers: %@", navController.viewControllers);
    [navController popToRootViewControllerAnimated:YES];
}

#pragma mark - Color Mixing

/**
 Mix ball's color with bucket's color and use this new color to paint the bucket
 */
- (void)mixBallColor:(BVBall *)ball intoBucket:(BVBucket *)bucket
{
    // we'll use userData value instead of bucket.color because [SKAction colorizeWithColor:] sometimes save exponent units as rgb values.
    UIColor *newBucketColor = [BVColor mixEmUp:@[[bucket.userData objectForKey:@"bucketColor"], ball.color]];
    // as animation will take time to complete, we need to store our new bucket color in it's userData for instant use.
    [bucket.userData setObject:newBucketColor forKey:@"bucketColor"];
    
    SKAction *changeBucketColor = [SKAction colorizeWithColor:newBucketColor colorBlendFactor:0.0 duration:0.5];
    [bucket runAction:changeBucketColor completion:^{
        // for info only
        const CGFloat *components = CGColorGetComponents([bucket.color CGColor]);
//        NSLog(@"r:%f, g:%f, b:%f", components[0], components[1], components[2]);
    }];
}

#pragma mark - Hud Related

- (void)hudAddPoints:(BVLevelRatingPointsType)pointsType withLabelOverBucket:(BVBucket *)bucket
{
    CGPoint bucketPosInRack = [_bucketsRack bucketPosInRack:bucket];
    CGPoint bucketPosInLevel = [_bucketsRack convertPoint:bucketPosInRack toNode:self];
    bucketPosInLevel = CGPointMake(bucketPosInLevel.x, bucketPosInLevel.y + (bucket.size.height / 2));
    
    // then update points and add label animation on top of the hitted bucket
    [_hudBottom.levelRating addPointsType:pointsType withLabelAnimationAt:bucketPosInLevel];
}

#pragma mark - Animation
- (void)moveContentOutWithCompletion:( void(^)() )completion
{
    // now animate level content to the final position
    SKAction *moveToTop = [SKAction moveToY:_screenSize.height duration:0.5];
    SKAction *moveToBottom = [SKAction moveToY:-_screenSize.height duration:0.5];
    
    [_hudTop runAction:moveToTop];
    [_ballsRack runAction:moveToTop];

    [_hudBottom runAction:moveToBottom];
    [_bucketsRack runAction:moveToBottom completion:completion]; // last element will run the completion block
    
    
}

#pragma mark - Flying Objects Related

- (void)addFlyingObjectsToLevel:(NSDictionary *)objectsInfo
{
    NSArray *objects = [objectsInfo objectForKey:@"objects"];
    NSArray *scrollingDirections = [objectsInfo objectForKey:@"scrollingDirections"];
    NSArray *scrollingSpeeds = [objectsInfo objectForKey:@"scrollingSpeeds"];
    NSArray *rolling = [objectsInfo objectForKey:@"rolling"];
    NSArray *backAndForthRow = [objectsInfo objectForKey:@"backAndForthRow"];
    BOOL switchRows = [[objectsInfo objectForKey:@"switchRows"] boolValue];
    
    float margin = [BVSize valueOniPhones:50 andiPads:40];
    _flyingObjectsCanvas = [[BVFlyingObjectsCanvas alloc] initWithObjects:objects scrollingDirections:scrollingDirections scrollingSpeeds:scrollingSpeeds backAndForthRows:backAndForthRow rolling:rolling switchRows:switchRows];
    _flyingObjectsCanvas.zPosition = 2.0;
    _flyingObjectsCanvas.level = self;
    [_flyingObjectsCanvas setPosRelativeTo:_ballsRack.frame side:BVPosSideBottom margin:margin];
    [self addChild:_flyingObjectsCanvas];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [_ballsRack touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [_ballsRack touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [_ballsRack touchesEnded:touches withEvent:event];
}

#pragma mark - External Button Handler

- (void)showGuidePageViewController
{
    // update viewController's Level property
    // Note: this will save us from a bug that messes up with the current state of the level, and
    // instead restarts the level which was first selected from level select page.
    [self updatePresentingLevelViewControllersProp];
    [self pauseGame];
    
    UINavigationController *navigationController = (UINavigationController *)self.scene.view.window.rootViewController;
    UIViewController *currentViewController = navigationController.visibleViewController;
    GuideViewController *guideViewController = [currentViewController.storyboard instantiateViewControllerWithIdentifier:@"GuideViewController"];
    [navigationController presentViewController:guideViewController animated:YES completion:nil];
}

#pragma mark - Notification Handler

- (void)guideViewControllerGotDismissed
{
    [self resumeGame];
}

#pragma mark - Particle Effect Methods

- (SKEmitterNode *)ballExplosion:(BVBall *)ball At:(CGPoint)point
{
    SKEmitterNode *ballExplosion = [BVParticle BallExplosion];
    ballExplosion.position = point;
    ballExplosion.particleColor = ball.color;
    ballExplosion.particleColorBlendFactor = 1.0;
    ballExplosion.particleColorSequence = nil;
    
    return ballExplosion;
}

- (void)explodeBall:(BVBall *)ball at:(CGPoint)position
{
    // play ball popping sound
    [self runAction:[BVSounds ballPops]];
    
    SKEmitterNode *ballExplosion = [self ballExplosion:ball At:position];
    [self addChild:ballExplosion];
    
    // now destroy the ball
    [self ballHitDestroyer:ball];
}

- (void)explodeCapAt:(CGPoint)capPos withBall:(BVBall *)ball
{
    // play destruction sound
    [self runAction:[BVSounds bomb]];
    
    SKEmitterNode *bombExplosion = [BVParticle BombBallExplosion];
    bombExplosion.position = CGPointMake(capPos.x, capPos.y - (ball.size.height / 4));
    [self addChild:bombExplosion];
    
    // also add some bomb smoke
    SKEmitterNode *ballSmoke = [BVParticle BombSmoke];
    ballSmoke.position = CGPointMake(capPos.x, capPos.y + (ball.size.height / 4));
    [self addChild:ballSmoke];
    
    // now destroy the ball
    [self ballHitDestroyer:ball];
}

#pragma mark - Interstitial Method

/**
 This method is called by BVAds's interstitial protocol method after dismissing the ad.
 */
- (void)interstitialDismissed
{
    // restart the level now
//    [self restartLevel];
}

#pragma mark - Utility Methods

- (void)showLevelIntroducerPopup
{
    CGSize dialogSize = CGSizeMake(_screenSize.width * 0.9, _screenSize.height * 0.6);
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dialogSize.width, dialogSize.height)];
    dialog.backgroundColor = [BVColor r:179 g:236 b:255];//[UIColor colorWithWhite:1 alpha:0.95];
    dialog.layer.cornerRadius = 5.0;
    
    float dialogMidX = CGRectGetMidX(dialog.frame);
    float distanceY = [BVSize valueOniPhones:10 andiPads:20];
    float normalFontSize = [BVSize valueOniPhones:16 andiPads:24];
    float smallFontSize = [BVSize valueOniPhones:14 andiPads:22];
    
// (1)
    // add level number label view
    UILabel *levelNum = [[UILabel alloc] init];
    levelNum.text = [NSString stringWithFormat:@"Level %i - Your Goal", _levelNum];
    levelNum.backgroundColor = [UIColor clearColor];
    levelNum.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:20 andiPads:28]];
    levelNum.textColor = [UIColor whiteColor];
    levelNum.textAlignment = NSTextAlignmentCenter;
    [levelNum sizeToFit];
    CGSize levelNumSize = levelNum.frame.size;
    levelNum.frame = CGRectMake(0, 0, levelNumSize.width + 50, levelNumSize.height + 10);
    levelNum.center = CGPointMake(dialogMidX, 0);
    
        // add a background image for levelNum
    UIView *levelNumBack = [[UIView alloc] init];
    levelNumBack.backgroundColor = [BVColor r:5 g:58 b:78 alpha:0.96];//[BVColor r:56 g:63 b:65 alpha:0.96];
    levelNumBack.layer.cornerRadius = 5;
    levelNumBack.frame = levelNum.frame;
    
    [dialog addSubview:levelNumBack]; // adding background view before adding label will keep it in background of label (common sense)
    [dialog addSubview:levelNum];
    
// (2)
//    // add instruction label 1
    CGSize instructionLabel1Size = CGSizeMake(dialogSize.width * 0.9, normalFontSize*3); // remember: sizeToFit will take care of the height
    UILabel *instructionLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(dialogMidX - (instructionLabel1Size.width/2), CGRectGetMaxY(levelNumBack.frame) + distanceY, instructionLabel1Size.width, instructionLabel1Size.height)];
    instructionLabel1.textAlignment = NSTextAlignmentCenter;
    instructionLabel1.font = [UIFont fontWithName:BVdefaultFontName() size:normalFontSize];
    instructionLabel1.lineBreakMode = NSLineBreakByWordWrapping;
    instructionLabel1.numberOfLines = 2;
    instructionLabel1.text = (_goalTargets.count > 1) ? @"Drop matching balls in given pipes" : @"Drop matching ball(s) in given pipe"; // @"Fill these pipes with matching balls" : @"Fill this pipe with matching ball(s)";
    [dialog addSubview:instructionLabel1];
    
// (3) show goal buckets
    // add goal scroll view
    float goalScrollViewHeight = [BVSize valueOniPhones:120 andiPads:200];
    UIScrollView *goalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(instructionLabel1.frame) + distanceY, dialogSize.width, goalScrollViewHeight)];
    goalScrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    
    // add bucket holder view
    UIView *bucketHolderView = [[UIView alloc] init];
    // 25.5 x 34
    CGSize bucketViewSize = [BVSize sizeOniPhones:CGSizeMake(25, 35) andiPads:CGSizeMake(45, 60)];
    UIImageView *prevBucketView = nil;
    for (NSDictionary *goalInfo in _goalTargets) {
        UIColor *goalColor = [goalInfo objectForKey:@"targetColor"];
        int goalTarget = [[goalInfo objectForKey:@"target"] intValue];
        float bucketDistance = [BVSize valueOniPhones:20 andiPads:30];
        float bucketY = CGRectGetHeight(goalScrollView.frame)/2 + (bucketViewSize.height/1.5);
        UIImageView *bucketView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bucketViewSize.width, bucketViewSize.height)];
        bucketView.backgroundColor = goalColor;
        
        // position it
        if (prevBucketView == nil) {
            // first bucket
            bucketView.center = CGPointMake(bucketViewSize.width/2, bucketY);
        }
        else {
            // second or ... bucket
            bucketView.center = CGPointMake(CGRectGetMaxX(prevBucketView.frame) + (bucketViewSize.width/2) + bucketDistance, bucketY);
        }
        
        // add target label
//        UILabel *targetLabel = [[UILabel alloc] init];
//        targetLabel.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:14 andiPads:22]];
//        targetLabel.text = [NSString stringWithFormat:@"%i", goalTarget];
//        targetLabel.textColor = [UIColor whiteColor];
//        targetLabel.textAlignment = NSTextAlignmentCenter;
//        [targetLabel sizeToFit];
//        CGSize targetLabelSize = targetLabel.frame.size;
//        targetLabel.frame = CGRectMake(bucketViewSize.width/2 - targetLabelSize.width/2, targetLabelSize.height/4, targetLabelSize.width, targetLabelSize.height);
        
        // create bucket colored ball and add target label on it
        UIView *ballView = [[UIView alloc] initWithFrame:CGRectMake(bucketView.frame.origin.x, bucketView.frame.origin.y - (bucketViewSize.height * 2), bucketViewSize.width, bucketViewSize.width)];
        ballView.layer.cornerRadius = bucketViewSize.width/2;
        ballView.backgroundColor = goalColor;
//        [ballView addSubview:targetLabel];
        
        // add ball cover
        UIImageView *ballCover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball-cover"]];
        ballCover.frame = CGRectMake(0, 0, bucketViewSize.width, bucketViewSize.width);
        [ballView addSubview:ballCover];
        
        // add ball into holder
        [bucketHolderView addSubview:ballView];

        // now add down arrow just under the ball
        CGSize arrowSize = [BVSize sizeOniPhones:CGSizeMake(25, 30) andiPads:CGSizeMake(40, 45)];
        UIImage *downArrowImg = [UIImage imageNamed:@"down-arrow-yellow"];
        UIImageView *downArrow = [[UIImageView alloc] initWithImage:downArrowImg];
        downArrow.frame = CGRectMake(CGRectGetMidX(bucketView.frame) - arrowSize.width/2, CGRectGetMaxY(ballView.frame) + arrowSize.height*0.2, arrowSize.width, arrowSize.height);
        [bucketHolderView addSubview:downArrow];
        
        /* Adding Bucket Labels - (START) */
        
        UILabel *bucketTargetLabel = [[UILabel alloc] init];
        bucketTargetLabel.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:14 andiPads:22]];
        bucketTargetLabel.text = [NSString stringWithFormat:@"%i", goalTarget];
        bucketTargetLabel.textColor = [UIColor whiteColor];
        bucketTargetLabel.textAlignment = NSTextAlignmentCenter;
        [bucketTargetLabel sizeToFit];
        CGSize targetLabelSize = bucketTargetLabel.frame.size;
        bucketTargetLabel.frame = CGRectMake(bucketViewSize.width/2 - targetLabelSize.width/2, targetLabelSize.height/1.5, targetLabelSize.width, targetLabelSize.height);
        [bucketView addSubview:bucketTargetLabel];
        
//        UILabel *bucketDescLabel1 = [[UILabel alloc] init];
//        bucketDescLabel1.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:8 andiPads:16]];
//        bucketDescLabel1.text = @"Add";
//        bucketDescLabel1.textColor = [UIColor colorWithWhite:1 alpha:0.5];
//        bucketDescLabel1.textAlignment = NSTextAlignmentCenter;
//        [bucketDescLabel1 sizeToFit];
//        bucketDescLabel1.center = CGPointMake(CGRectGetMidX(bucketTargetLabel.frame), CGRectGetMinY(bucketTargetLabel.frame));
//        [bucketView addSubview:bucketDescLabel1];
//        
//        NSString *bucketDescLabel2Txt = (goalTarget > 1) ? @"Balls" : @"Ball";
//        UILabel *bucketDescLabel2 = [[UILabel alloc] init];
//        bucketDescLabel2.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:8 andiPads:16]];
//        bucketDescLabel2.text = bucketDescLabel2Txt;
//        bucketDescLabel2.textColor = [UIColor colorWithWhite:1 alpha:0.5];
//        bucketDescLabel2.textAlignment = NSTextAlignmentCenter;
//        [bucketDescLabel2 sizeToFit];
//        bucketDescLabel2.center = CGPointMake(CGRectGetMidX(bucketTargetLabel.frame), CGRectGetMaxY(bucketTargetLabel.frame));
//        [bucketView addSubview:bucketDescLabel2];
        
        /* Adding Bucket Labels - (END) */
        
        // add bucket cover
        UIImageView *cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goal-bucket-cover"]];
        cover.frame = CGRectMake(0, 0, bucketView.frame.size.width, bucketView.frame.size.height);
        [bucketView addSubview:cover];
        
        [bucketHolderView addSubview:bucketView];
        
        prevBucketView = bucketView;
    }
    
    CGSize bucketHolderViewSize = [BVUtility calculateViewArea:bucketHolderView];
    bucketHolderView.frame = CGRectMake(0, 0, bucketHolderViewSize.width, bucketHolderViewSize.height);
    
    if (bucketHolderViewSize.width < CGRectGetWidth(goalScrollView.frame)) {
        // center the content of goalScrollView if it's smaller than it's width
        bucketHolderView.center = CGPointMake(goalScrollView.center.x, CGRectGetHeight(goalScrollView.frame)/2);
    }
    else {
        // start displaying goal bucket's from left side
        bucketHolderView.center = CGPointMake(bucketHolderViewSize.width/2, CGRectGetHeight(goalScrollView.frame)/2);
    }
    
    // add bucket holder view to scroll view
    [goalScrollView addSubview:bucketHolderView];
    
    // calculate content size of scrollview
    goalScrollView.contentSize = bucketHolderView.frame.size;
    [dialog addSubview:goalScrollView];
    
// (4)
    // data
    int moves = [[_goalOptions objectForKey:@"moves"] intValue];
    int time = [[_goalOptions objectForKey:@"timer"] intValue];
    
    // add instruction label 2
    CGSize labelSize = CGSizeMake(dialogSize.width * 0.9, normalFontSize + 5);
    UILabel *instructionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 0)];
    instructionLabel2.font = [UIFont fontWithName:BVdefaultFontName() size:normalFontSize];
    instructionLabel2.textAlignment = NSTextAlignmentCenter;
    instructionLabel2.lineBreakMode = NSLineBreakByWordWrapping;
    instructionLabel2.numberOfLines = 1;
    
    // setup label text string
    NSString *instruction2Str = [NSString stringWithFormat:@"You have %i %@%@", moves, (moves > 1) ? @"moves" : @"move", (time >= 1) ? [NSString stringWithFormat:@" and %i sec", time] : @""];
    
    instructionLabel2.text = instruction2Str;
    [instructionLabel2 sizeToFit];
    instructionLabel2.frame = CGRectMake(dialogMidX - (labelSize.width/2), CGRectGetMaxY(goalScrollView.frame) + distanceY, labelSize.width, instructionLabel2.frame.size.height);
    [dialog addSubview:instructionLabel2];
    
// (5)
    // add dismiss button
    float buttonWidth = dialogSize.width * 0.6;
    CGSize buttonSize = [BVSize sizeOniPhones:CGSizeMake(buttonWidth, 40) andiPads:CGSizeMake(buttonWidth, 70)];
    BVButton *okButton = [BVButton GreenButtonWithText:@"Got It" fontSize:normalFontSize size:buttonSize];
    okButton.center = CGPointMake(CGRectGetMidX(dialog.frame), CGRectGetMaxY(instructionLabel2.frame) + buttonSize.height/2 + distanceY);
    [okButton addTarget:self action:@selector(dismissGoalIntroducer:) forControlEvents:UIControlEventTouchUpInside];
    [dialog addSubview:okButton];
    
// (6)
    // add hint label if any
    if (_lvlHint) {
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(dialogMidX - (instructionLabel1Size.width/2), CGRectGetMaxY(okButton.frame) + distanceY, instructionLabel1Size.width, instructionLabel1Size.height)];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.textColor = [BVColor r:183 g:31 b:87];
        hintLabel.font = [UIFont fontWithName:BVdefaultFontName() size:smallFontSize];
        hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
        hintLabel.numberOfLines = 2;
        hintLabel.text = [NSString stringWithFormat:@"Hint: %@", _lvlHint];
        [dialog addSubview:hintLabel];
    }
    
    CGSize newDialogSize = [BVUtility calculateViewArea:dialog];
    dialog.frame = CGRectMake(0, 0, newDialogSize.width, newDialogSize.height + distanceY);
    
    KLCPopup *levelIntroducerPopup = [KLCPopup popupWithContentView:dialog showType:KLCPopupShowTypeSlideInFromRight dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    levelIntroducerPopup.didFinishDismissingCompletion = ^{
        [self fadeInContentAfterDismissingGoalIntroducer];
    };
    
    okButton.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"popup": levelIntroducerPopup}];
    
    [levelIntroducerPopup show];
}

- (void)dismissGoalIntroducer:(BVButton *)sender
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    KLCPopup *presentingPopup = [sender.userData objectForKey:@"popup"];
    [presentingPopup dismiss:YES];
    
    [sender.userData removeAllObjects];
}

- (void)fadeInContentAfterDismissingGoalIntroducer
{
    [_hudTop runAction:[SKAction fadeInWithDuration:0.5]];
    _ballsRack.alpha = 1.0;
    [_flyingObjectsCanvas runAction:[SKAction fadeInWithDuration:0.5]];
    [_bucketsRack runAction:[SKAction fadeInWithDuration:0.5]];
    [_hudBottom runAction:[SKAction fadeInWithDuration:0.5] completion:^{
        // start the timer after presenting the _hudBottom
        _hudBottom.timerPaused = NO;
    }];
}

- (void)stopLevelWithReason:(NSString *)reason
{
    // pause the timer
    _hudBottom.timerPaused = YES;
    
    __weak BVLevel *weakSelf = self;
    KLCPopup *popup = [KLCPopup popupWithContentView:[self levelEndingReason:reason didWon:NO] showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
    
    popup.didFinishDismissingCompletion = ^() {
        
        if ([[BVGameData sharedGameData] shouldDisplayAds]) {
            // present interstitial ad
            [_ads presentInterstitialAdFromRootVC:weakSelf.scene.view.window.rootViewController];
        }
        
        [weakSelf restartLevel];
    };
    
    [popup showWithDuration:0.0];
}

- (UIView *)levelEndingReason:(NSString *)text didWon:(BOOL)didWon
{
    NSString *reasonBackImg = (didWon) ? @"win-text-back" : @"reason-view-back";
    UIView *wrapper = [[UIView alloc] init];
    wrapper.frame = CGRectMake(0, 0, self.size.width, (self.size.height * 0.20));
    wrapper.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:reasonBackImg]];
    wrapper.layer.shadowOffset = CGSizeMake(0, 2);
    wrapper.layer.shadowRadius = 2;
    wrapper.layer.shadowOpacity = 0.3;
    //wrapper.layer.shadowColor = [UIColor whiteColor].CGColor;
    
    float wrapperWidth = CGRectGetWidth(wrapper.frame);
    float wrapperHeight = CGRectGetHeight(wrapper.frame);
    
    UILabel *reasonText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (wrapperWidth * 0.85), (wrapperHeight * 0.75))];
    reasonText.center = wrapper.center;
    reasonText.textAlignment = NSTextAlignmentCenter;
    reasonText.numberOfLines = 0;
    reasonText.text = text;
    reasonText.font = [UIFont fontWithName:BVdefaultFontName() size:BVdynamicFontSizeWithFactor(_screenSize, 0.06)];
    reasonText.textColor = [UIColor whiteColor];
    reasonText.shadowColor = [UIColor colorWithRed:78/255.0 green:49/255.0 blue:0/255.0 alpha:1.0];
    reasonText.shadowOffset = CGSizeMake(0, 1.5);
    [wrapper addSubview:reasonText];
    
    return wrapper;
}

- (void)addBallCollisionEnabler
{
    _ballCollisionEnabler = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(_screenSize.width, 1)];
    _ballCollisionEnabler.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ballCollisionEnabler.size];
    _ballCollisionEnabler.physicsBody.affectedByGravity = NO;
    _ballCollisionEnabler.physicsBody.dynamic = NO;
    _ballCollisionEnabler.physicsBody.categoryBitMask = PhysicsCategoryBallCollisionEnabler;
    _ballCollisionEnabler.physicsBody.contactTestBitMask = PhysicsCategoryBall;
    [self addChild:_ballCollisionEnabler];
}

- (void)updatePresentingLevelViewControllersProp
{
    // get navigation controller reference
    UINavigationController *navController = (UINavigationController *)self.scene.view.window.rootViewController;
    
    // we need to update our PlayLevelViewController class with latest information before leaving this level.
    // unless that class will going to re-instantiate level and quickly deallocate it.
    // because it use's didLayoutSubviews method which get's called at beginning and ending
    // and that method won't do unexpected behaviour if we update it's levelNum property
    ((PlayLevelViewController *)navController.visibleViewController).levelNum = _levelNum;
}

/**
 Use this method to extract color from name of bucket or ball
 */
- (NSString *)getColorFromName:(NSString *)name
{
    // name should be like solid-red, solid-green etc.
    return [[name componentsSeparatedByString:@"-"] lastObject];
}

- (void)stopAllTouches
{
    self.userInteractionEnabled = NO;
    _ballsRack.userInteractionEnabled = NO;
    _bucketsRack.userInteractionEnabled = NO;
    
    [_ballsRack stopUserInteractionOnAllBalls];
}

- (void)stopTouchesExcludingBucketRack
{
    [self stopAllTouches];
    
    _bucketsRack.userInteractionEnabled = YES;
}

- (void)removeNotifications
{
    // Remove notification observer.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BVBallGotReleased" object:nil];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
