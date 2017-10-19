//
//  MainViewController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//
#import "MainViewController.h"
#import "BVGameData.h"
#import "BVLevelsData.h"
#import "MainScene.h"
#import "PlayLevelViewController.h"
#import "LevelsViewController.h"
#import "PlaygroundViewController.h"
#import "BVColor.h"
#import <Google/Analytics.h>

@implementation MainViewController
{
    SKView *_skView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [BVColor r:137 g:226 b:255];
    
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.text = @"Ready? Let's Go!";
    loadingLabel.textColor = [UIColor darkGrayColor];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    [loadingLabel sizeToFit];
    loadingLabel.center = self.view.center;
    [self.view addSubview:loadingLabel];
    
    // ONLY DO THIS FOR ONCE IN THE LIFETIME
    [self firstTimeSetup];
    
//    [[BVGameData sharedGameData] disableAds];
//    [self unlockLevelsUpto:20];
//
//    NSLog(@"defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MainViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if (!_skView) {
        // create skview
        _skView = [[SKView alloc] initWithFrame:self.view.frame];
        
        if (!_skView.scene) {
            // load scene
            SKScene *scene = [[MainScene alloc] init];
            [_skView presentScene:scene];
        }
        
        [self.view addSubview:_skView];
    }
}

#pragma mark - Utility Methods

- (void)goToRecentLevel
{
    PlayLevelViewController *recentLevel = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"PlayLevelViewController"];
    recentLevel.levelNum = (int)[[BVGameData sharedGameData] recentLevelNum];
    recentLevel.presentingFromHomePage = YES;
    [self clearUpSKViewAndGoTo:recentLevel];
}

- (void)goToLevels
{
    LevelsViewController *levelsViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"LevelsViewController"];
    [self clearUpSKViewAndGoTo:levelsViewController];
}

- (void)goToPlayground
{
    PlaygroundViewController *playgroundViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"PlaygroundViewController"];
    [self clearUpSKViewAndGoTo:playgroundViewController];
}

- (void)clearUpSKViewAndGoTo:(UIViewController *)vc
{
    UINavigationController *nav = self.navigationController;
    
    [UIView animateWithDuration:0.5 animations:^{
        _skView.alpha = 0;
    } completion:^(BOOL finished) {
        [_skView removeFromSuperview];
        _skView = nil;
        
        [nav pushViewController:vc animated:YES];
    }];
}

#pragma mark - Defaults

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - First Time Setup

- (void)firstTimeSetup
{
    // unlock first level by default
    NSDictionary *firstLevelData = [[BVGameData sharedGameData] dataForLevel:1];
    BOOL isFirstLevelLocked = ([[firstLevelData objectForKey:@"locked"] boolValue] == YES);
    if (isFirstLevelLocked) {
        // set data for first level
        [[BVGameData sharedGameData] saveLevel:1 data:@{@"passed": @NO,
                                                        @"pointsEarned": @0,
                                                        @"starsEarned": @0,
                                                        @"locked": @NO}];
        
        // enable game sound for first time
        [[BVGameData sharedGameData] enableSound];
        // display ads by default
        [[BVGameData sharedGameData] enableAds];
        // set recent level value to 1. (we want to load level 1 by default when user presses play button on homepage)
        [[BVGameData sharedGameData] saveRecentLevelNum:1];
        
        [self setCoins:0];
    }
}


#pragma mark - FOR TESTING PURPOSE ONLY (MUST NOT BE INCLUDED IN PRODUCTION VERSION)

- (void)unlockLevelsUpto:(int)levelNum
{
    // UNLOCK ALL LEVELS BY DEFAULT TO TEST FUNCTIONALITY
    for (int i = 1; i<=[BVLevelsData totalLevels]; i++) {
        if (i <= levelNum) {
            [[BVGameData sharedGameData] saveLevel:i data:@{@"passed": @NO,
                                                            @"pointsEarned": @0,
                                                            @"starsEarned": @0,
                                                            @"locked": @NO}];
        }
        else {
            [[BVGameData sharedGameData] saveLevel:i data:@{@"passed": @NO,
                                                            @"pointsEarned": @0,
                                                            @"starsEarned": @0,
                                                            @"locked": @YES}];
        }
    }
}

- (void)reLockAllLevels
{
    // UNLOCK ALL LEVELS BY DEFAULT TO TEST FUNCTIONALITY
    for (int i = 2; i<=[BVLevelsData totalLevels]; i++) {
        [[BVGameData sharedGameData] saveLevel:i data:@{@"passed": @NO,
                                                        @"pointsEarned": @0,
                                                        @"starsEarned": @0,
                                                        @"locked": @YES}];
    }
}

- (void)setCoins:(int)coins
{
    [[BVGameData sharedGameData] saveCoins:coins];
}

@end
