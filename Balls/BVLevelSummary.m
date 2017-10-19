//
//  LevelSummary.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/26/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVLevelSummary.h"
#import "BVLabelNode.h"
#import "BVHud.h"
#import "BVSize.h"
#import "AGSpriteButton.h"
#import "SKSpriteNode+BVPos.h"
#import "BVColor.h"
#import "BVLevelsData.h"
#import "BVUtility.h"
#import "BVRollingThings.h"
#import "BVTransition.h"
#import "BVLevelLoader.h"
#import "BVSounds.h"

#import "MainViewController.h"
#import "LevelsViewController.h"

#define percent(percentage, number) ((percentage * number) / 100)

@implementation BVLevelSummary
{
    AGSpriteButton *_levelsPageButton;
    AGSpriteButton *_replayLevelButton;
    AGSpriteButton *_nextLevelButton;
    AGSpriteButton *_shareLevelProgressButton;
    SKSpriteNode *_progressBar;
    int _levelNum;
    NSDictionary *_summary;
    BOOL _presentingFromHomePage;
}

- (instancetype)initWithSummary:(NSDictionary *)summary ofLevel:(int)level presentingFromHomePage:(BOOL)presentingFromHomePage
{
    self = [super init];
    
    if (self) {
        self.size = [BVSize originalScreenSize];
        self.backgroundColor = [BVColor r:137 g:226 b:255];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.scaleMode = SKSceneScaleModeResizeFill;
        
        // store level number in instance variable, because we'll need it in some methods
        _levelNum = level;
        _summary = summary;
        _presentingFromHomePage = presentingFromHomePage;
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    CGSize size = [BVSize originalScreenSize];
    
    int starsEarned = [[_summary objectForKey:@"starsEarned"] intValue];
    NSArray *points = [_summary objectForKey:@"pointsEarnedAndTarget"];
    CGSize screenSize = [BVSize originalScreenSize];
    
    // add trees background
    SKSpriteNode *trees = [[[BVRollingThings alloc] init] grass];
    trees.position = CGPointMake(0, -(screenSize.height / 2) + (trees.size.height/2));
    trees.zPosition = 1;
    [self addChild:trees];
    
    
    CGSize plateSize = [BVSize resizeUniversally:CGSizeMake(270, 455) firstTime:YES];
    
    SKShapeNode *plate = [SKShapeNode shapeNodeWithRectOfSize:plateSize];
    plate.fillColor = [BVColor r:179 g:236 b:255];
    plate.lineWidth = 0.5;
    plate.strokeColor = [BVColor r:108 g:184 b:209];
    plate.position = CGPointMake(0, 0);
    
    /**
     ADD LEVEL PASSED BANNER
     **/
    // move in level passed banner from top
    SKSpriteNode *levelPassedBanner = [SKSpriteNode spriteNodeWithImageNamed:@"summary-level-passed-banner"];
    levelPassedBanner.size = [BVSize resizeUniversally:CGSizeMake(298, 51) firstTime:YES];
    [levelPassedBanner setPosRelativeTo:plate.frame side:BVPosSideTop margin:[BVSize valueOniPhones:-(levelPassedBanner.size.height/2) andiPads:-(levelPassedBanner.size.height/3)]];
    [plate addChild:levelPassedBanner];
    
    // add level banner text
    BVLabelNode *levelBannerText = [BVLabelNode labelWithText:[NSString stringWithFormat:@"Level %i Passed", _levelNum]];
    levelBannerText.fontSize = [BVSize valueOniPhones:16 andiPads:32];
    levelBannerText.fontColor = [BVColor whiteColor];
    levelBannerText.position = CGPointMake(0, 4);
    levelBannerText.zPosition = levelPassedBanner.zPosition+1;
    [levelPassedBanner addChild:levelBannerText];
    
    // run animation on that banner
//    [levelPassedBanner runAction:[SKAction moveByX:0 y:-(levelPassedBanner.size.height * 1.2) duration:0.3]];
    
    /**
     ADD STARS
     **/
    CGSize emptyStarSize = [BVSize resizeUniversally:CGSizeMake(62, 59) firstTime:YES];
    CGSize earnedStarSize = [BVSize resizeUniversally:CGSizeMake(62, 59) firstTime:YES];
    SKSpriteNode *starsHolder = [SKSpriteNode node];
    starsHolder.zPosition = 10;
    starsHolder.anchorPoint = CGPointMake(0, 0.5);
    NSMutableArray *emptyStars = [NSMutableArray array];
    NSMutableArray *earnedStars = [NSMutableArray array];
    
    // add empty stars
    for (int i=0; i<3; i++) {
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"summary-star-empty"];
        star.anchorPoint = CGPointMake(0, 0.5);
        star.size = emptyStarSize;
        star.position = CGPointMake((emptyStarSize.width * 1.2) * i, 0);
        [starsHolder addChild:star];
    
        [emptyStars addObject:star];
    }
    
    // add earned stars but kepp their alpha = 0 (we'll animate them later)
    for (int i=0; i<starsEarned; i++) {
        SKSpriteNode *earnedStar = [SKSpriteNode spriteNodeWithImageNamed:@"summary-star-earned"];
        earnedStar.alpha = 0;
        earnedStar.anchorPoint = CGPointMake(0, 0.5);
        earnedStar.size = earnedStarSize;
        earnedStar.position = ((SKSpriteNode *)[emptyStars objectAtIndex:i]).position;
        [starsHolder addChild:earnedStar];
        
        [earnedStars addObject:earnedStar];
    }
    
    starsHolder.size = [starsHolder calculateAccumulatedFrame].size;
    starsHolder.position = CGPointMake(-(starsHolder.size.width/2), CGRectGetMaxY(levelPassedBanner.frame) - (levelPassedBanner.size.height * 1.2) - (starsHolder.size.height));
    [plate addChild:starsHolder];
    
    // scale earned stars to be twice their current size
    // we can't do it in the loop where we initialized each star, because
    // that messes up with the size of starsHolder
    for (SKSpriteNode *earnedStar in earnedStars) {
        [earnedStar setScale:2];
    }
    
    // animate the earned stars
    // we could've used for loop here, but we want to animate them one by one
    if (earnedStars.count > 0) {
        // first star
        SKSpriteNode *earnedStar = [earnedStars objectAtIndex:0];
        [earnedStar runAction:[SKAction fadeInWithDuration:0.4]];
        [earnedStar runAction:[SKAction scaleTo:1 duration:0.4] completion:^{
            
            if (earnedStars.count > 1) {
                // second star
                SKSpriteNode *earnedStar = [earnedStars objectAtIndex:1];
                [earnedStar runAction:[SKAction fadeInWithDuration:0.4]];
                [earnedStar runAction:[SKAction scaleTo:1 duration:0.4] completion:^{
                    
                    if (earnedStars.count > 2) {
                        // third star
                        SKSpriteNode *earnedStar = [earnedStars objectAtIndex:2];
                        [earnedStar runAction:[SKAction fadeInWithDuration:0.4]];
                        [earnedStar runAction:[SKAction scaleTo:1 duration:0.4]];
                    }
                    
                }];
            }
            
        }];
    }
    
    
    /**
     POINTS PROGRESS BAR
     **/
    CGSize progressBodySize = [BVSize resizeUniversally:CGSizeMake(227, 46) firstTime:YES];
    UIColor *progressBarColor = [BVColor r:81 g:183 b:0];
    UIColor *progressBarColorTwo = [BVColor r:81 g:200 b:0];
    // progress bar
    _progressBar = [SKSpriteNode spriteNodeWithColor:progressBarColor size:CGSizeMake(percent(0, progressBodySize.width), progressBodySize.height * 0.95)];
    _progressBar.anchorPoint = CGPointMake(0, 0.5);
    _progressBar.zPosition = 1;
    
    // add infinite glow animation to progress bar
    SKAction *glow = [SKAction sequence:@[[SKAction colorizeWithColor:progressBarColorTwo colorBlendFactor:0.0 duration:1.0],
                                          [SKAction colorizeWithColor:progressBarColor colorBlendFactor:0.0 duration:1.0],
                                          [SKAction waitForDuration:0.2]]];
    glow = [SKAction repeatActionForever:glow];
    [_progressBar runAction:glow];

    // add points label
    int pointsEarned = [[points objectAtIndex:0] intValue];
    int pointsTarget = [[points objectAtIndex:1] intValue];
    BVLabelNode *pointsLabel = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%i / %i", pointsEarned, pointsTarget]];
    pointsLabel.fontSize = [BVSize valueOniPhones:18 andiPads:26];
    pointsLabel.fontColor = [BVColor r:4 g:94 b:0];
    pointsLabel.zPosition = _progressBar.zPosition+1;
    pointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    pointsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [_progressBar addChild:pointsLabel];

    
    // add glass body to it
    SKSpriteNode *progressBarBody = [SKSpriteNode spriteNodeWithImageNamed:@"summary-points-bar-body"];
    progressBarBody.size = progressBodySize;
    progressBarBody.zPosition = _progressBar.zPosition+2;
    progressBarBody.anchorPoint = CGPointMake(0, 0.5);
    progressBarBody.position = CGPointMake(-1, 0);
    [BVSize outputSize:progressBarBody.size msg:@"progressBarBody"];
    [_progressBar addChild:progressBarBody];
    
    // reset _progressBar and pointsLabel position
    _progressBar.position = CGPointMake(CGRectGetMidX(self.frame)-(progressBarBody.size.width/2), CGRectGetHeight(_progressBar.frame));
    pointsLabel.position = CGPointMake(CGRectGetWidth(progressBarBody.frame)/2, 0);
    
    [plate addChild:_progressBar];
    
    // let's run the progress bar animation
    float progressPercent = (pointsEarned * 100) / pointsTarget;
    SKAction *animateWidth = [SKAction resizeToWidth:percent(progressPercent, progressBarBody.size.width*0.99) duration:0.3];
    [_progressBar runAction:animateWidth];
    
    /**
     ADD BUTTONS
     **/
    
    // add a node which on touch will open up Level Select page
    CGSize bigButtonSize = [BVSize resizeUniversally:CGSizeMake(80, 80) firstTime:YES];
    CGSize smallButtonSize = [BVSize resizeUniversally:CGSizeMake(40, 40) firstTime:YES];
    
    _nextLevelButton = [AGSpriteButton buttonWithImageNamed:@"summary-next-level-icon"];
    _nextLevelButton.size = bigButtonSize;
    [_nextLevelButton setPosRelativeTo:_progressBar.frame side:BVPosSideBottom margin:[BVSize valueOniPhones:bigButtonSize.height/2 andiPads:bigButtonSize.height/4]];
    _nextLevelButton.zPosition = 10;
    [_nextLevelButton addTarget:self selector:@selector(presentNextLevel) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    
    [self addChild:_nextLevelButton];
    
    _levelsPageButton = [AGSpriteButton buttonWithImageNamed:@"level-menu-levels-icon"];
    _levelsPageButton.size = smallButtonSize;
    _levelsPageButton.position = CGPointMake(smallButtonSize.width + 20, CGRectGetMinY(_nextLevelButton.frame) - smallButtonSize.height);
    _levelsPageButton.zPosition = 10;
    [_levelsPageButton addTarget:self selector:@selector(showLevels) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [self addChild:_levelsPageButton];
    
    _replayLevelButton = [AGSpriteButton buttonWithImageNamed:@"level-menu-replay-icon"];
    _replayLevelButton.size = smallButtonSize;
    [_replayLevelButton setPosRelativeTo:_levelsPageButton.frame side:BVPosSideLeft margin:20];
    _replayLevelButton.position = CGPointMake(_replayLevelButton.position.x, _levelsPageButton.position.y);
    _replayLevelButton.zPosition = 10;
    [_replayLevelButton addTarget:self selector:@selector(representLastLevel) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [self addChild:_replayLevelButton];
    
    _shareLevelProgressButton = [AGSpriteButton buttonWithImageNamed:@"level-menu-share-icon"];
    _shareLevelProgressButton.size = smallButtonSize;
    [_shareLevelProgressButton setPosRelativeTo:_replayLevelButton.frame side:BVPosSideLeft margin:20];
    _shareLevelProgressButton.position = CGPointMake(_shareLevelProgressButton.position.x, _levelsPageButton.position.y);
    _shareLevelProgressButton.zPosition = 10;
    [_shareLevelProgressButton addTarget:self selector:@selector(showShareLevelProgressVC) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [self addChild:_shareLevelProgressButton];
    
    [self addChild:plate];
}

#pragma mark - Button Handlers

- (void)representLastLevel
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    // remove button targets
    [self removeButtonEvents];
    
    BVLevelLoader *level = [[BVLevelLoader alloc] initWithLevel:_levelNum size:[BVSize originalScreenSize] showGoalIntroducer:NO presentingFromHomePage:_presentingFromHomePage];
    BVTransition *transition = [[BVTransition alloc] init];
    [transition presentNewScene:level oldScene:self waitingText:@"Refreshing" block:^{}];
}

- (void)presentNextLevel
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    // remove button targets
    [self removeButtonEvents];
    
    int levelNum = _levelNum + 1;
    
    if (levelNum > [BVLevelsData totalLevels]) {
        levelNum = 1;
    }
    
    BVLevelLoader *level = [[BVLevelLoader alloc] initWithLevel:levelNum size:[BVSize originalScreenSize] showGoalIntroducer:YES presentingFromHomePage:_presentingFromHomePage];
    BVTransition *transition = [[BVTransition alloc] init];
    [transition presentNewScene:level oldScene:self waitingText:@"Refreshing" block:^{}];
}

- (void)showLevels
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    // remove button targets
    [self removeButtonEvents];
    
    // get navigation controller reference
    UINavigationController *navController = (UINavigationController *)self.scene.view.window.rootViewController;
    
    // clear up the scene
    [BVUtility cleanUpChildrenAndRemove:self];
    
    
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

- (void)showShareLevelProgressVC
{
    UIImage *viewImg = [BVUtility takeScreenshotOfView:self.view];
    NSURL *appUrl = [NSURL URLWithString:@"https://itunes.apple.com/app/ballspectrum/id1076067844"];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[@"I challenge you to beat my scores in this level of BallSpectrum", viewImg, appUrl] applicationActivities:nil];
    UIViewController *vc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
    [vc presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Utility Methods

- (void)removeButtonEvents
{
    [_replayLevelButton removeAllTargets];
    [_nextLevelButton removeAllTargets];
    [_levelsPageButton removeAllTargets];
    
    _replayLevelButton = nil;
    _nextLevelButton = nil;
    _levelsPageButton = nil;
}

@end
