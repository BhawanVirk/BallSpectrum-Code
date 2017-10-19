//
//  BVPlaygroundHud.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/31/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

@import GameKit;
#import "BVPlaygroundHud.h"
#import "BVLabelNode.h"
#import "BVSize.h"
#import "BVColor.h"
#import "SKSpriteNode+BVPos.h"
#import "AGSpriteButton.h"
#import "BVTransition.h"
#import "MainScene.h"
#import "BVGameData.h"
#import "UIColor+Mix.h"
#import "BVUtility.h"
#import "BVSounds.h"

#define percent(percentage, number) ((percentage * number) / 100)

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface BVPlaygroundHud ()

@end

@implementation BVPlaygroundHud
{
    int _bestScores;
    SKSpriteNode *_coinImg;
    SKSpriteNode *_tropyImg;
    SKSpriteNode *_progressLabelWrapper;
    BVLabelNode *_scoresLabel;
    AGSpriteButton *_backToHome;
    BVLabelNode *_scoresRecordLabel;
    BVLabelNode *_coinsLabel;
}

@synthesize score = _score;
@synthesize coinsCollected = _coinsCollected;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.size = [BVSize resizeUniversally:CGSizeMake(0, 50) firstTime:YES useFullWidth:YES];
        self.color = [UIColor clearColor];//[UIColor colorWithWhite:0 alpha:0.4];
        self.zPosition = 13;
        
        // setup buttons
        [self setupButtons];
        
        // add current score count label
        [self setupScoresLabel];
        
        // add best score and all time coins collection labels
        [self setupSoFarProgressLabels];
        
    }
    
    return self;
}

- (void)setupButtons
{
    _backToHome = [AGSpriteButton buttonWithTexture:[SKTexture textureWithImageNamed:@"crossmark"]];//[SKSpriteNode spriteNodeWithImageNamed:@"back-arrow"];
    _backToHome.size = [BVSize resizeUniversally:CGSizeMake(25, 25) firstTime:YES];
    _backToHome.position = CGPointMake(-(self.size.width/2) + (_backToHome.size.width/1.5), 0);
    [_backToHome addTarget:self selector:@selector(transitionToHomepage) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [self addChild:_backToHome];
}

- (void)setupScoresLabel
{
    _scoresLabel = [BVLabelNode labelWithText:@"0"];
    _scoresLabel.fontSize = BVdynamicFontSizeWithFactor([BVSize screenSize], 0.15);
    _scoresLabel.fontColor = [UIColor whiteColor];
    _scoresLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _scoresLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _scoresLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - (CGRectGetWidth(_scoresLabel.frame)), CGRectGetMinY(self.frame) - CGRectGetHeight(_scoresLabel.frame) / 2);
    [self addChild:_scoresLabel];

    self.score = 0;
}

- (void)setupSoFarProgressLabels
{
    _bestScores = [[BVGameData sharedGameData] bestScores];
    _progressLabelWrapper = [SKSpriteNode node];
    _progressLabelWrapper.anchorPoint = CGPointMake(0, 0.5);
    
    _coinsLabel = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%i", _coinsCollected]];
    _coinsLabel.fontSize = BVdynamicFontSizeWithFactor([BVSize screenSize], 0.08);
    _coinsLabel.fontColor = [BVColor yellow];
    _coinsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _coinsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _coinsLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - (CGRectGetWidth(_coinsLabel.frame) / 2), 0);
    [_progressLabelWrapper addChild:_coinsLabel];
    
    _coinImg = [SKSpriteNode spriteNodeWithImageNamed:@"Coin"];
    _coinImg.size = [BVSize resizeUniversally:CGSizeMake(25, 25) firstTime:YES];
    [_progressLabelWrapper addChild:_coinImg];
    
    _scoresRecordLabel = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%i", _bestScores]];
    _scoresRecordLabel.fontSize = _coinsLabel.fontSize;
    _scoresRecordLabel.fontColor = [UIColor whiteColor];
    _scoresRecordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _scoresRecordLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [_progressLabelWrapper addChild:_scoresRecordLabel];
    
    _tropyImg = [SKSpriteNode spriteNodeWithImageNamed:@"trophy-small"];
    _tropyImg.size = [BVSize resizeUniversally:CGSizeMake(20, 25) firstTime:YES];
    [_progressLabelWrapper addChild:_tropyImg];
    
    [self addChild:_progressLabelWrapper];
    
    self.coinsCollected = [[BVGameData sharedGameData] totalCoins];
}

- (void)resetScores
{
    // reset record label's font color. (it get's altered when user scores more than their best scores)
    _scoresRecordLabel.fontColor = [UIColor whiteColor];
    self.score = 0;
}

#pragma mark - Button Helpers

- (void)transitionToHomepage
{
    [self runAction:[BVSounds tap]];
    self.scene.paused = YES;
    
    UINavigationController *navController = (UINavigationController *)self.scene.view.window.rootViewController;
    
    // remove button reference
    [_backToHome removeAllTargets];
    [BVUtility cleanUpChildrenAndRemove:self.scene];
    
    [navController popViewControllerAnimated:YES];
}

#pragma mark - Utility Methods

- (void)repositionSoFarLabels
{
    _coinImg.position = CGPointMake((_coinsLabel.position.x - CGRectGetWidth(_coinsLabel.frame)) - (_coinImg.size.width / 1.5), 0);
    _scoresRecordLabel.position = CGPointMake(CGRectGetMinX(_coinImg.frame) - 20, 0);
    _tropyImg.position = CGPointMake((_scoresRecordLabel.position.x - CGRectGetWidth(_scoresRecordLabel.frame)) - (_tropyImg.size.width / 1.5), 0);
}

#pragma mark - Getter & Setter

- (void)setScore:(int)score
{
    _score = score;
    
    // update scores label
    _scoresLabel.text = [NSString stringWithFormat:@"%i", score];
    
    if (score > _bestScores) {
        _bestScores = score;
        
        // save data
        [[BVGameData sharedGameData] saveBestScores:_bestScores];
        
        // update local player's scores for game center leaderboard
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"infinity_land"];
        scoreReporter.value = _bestScores;
        
        [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"updated scores in leaderboard");
        }];
        
        // update best scores label too
        _scoresRecordLabel.text = [NSString stringWithFormat:@"%i", score];
        _scoresRecordLabel.fontColor = [BVColor green];
        
        [self repositionSoFarLabels];
    }
    
}

- (void)setCoinsCollected:(int)coinsCollected
{
    _coinsCollected = coinsCollected;
    
    // save data
    [[BVGameData sharedGameData] saveCoins:coinsCollected];
    
    // update coins label
    _coinsLabel.text = [NSString stringWithFormat:@"%i", coinsCollected];
    
    [self repositionSoFarLabels];
}

@end
