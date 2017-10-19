//
//  BVLevelMenu.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/21/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVLevelMenu.h"
#import "BVLevel.h"
#import "BVHud.h"
#import "BVSize.h"
#import "BVColor.h"
#import "AGSpriteButton.h"
#import "BVGameData.h"
#import "BVSounds.h"

@implementation BVLevelMenu
{
    SKSpriteNode *_content;
    SKSpriteNode *_background;
    AGSpriteButton *_levelsButton;
    AGSpriteButton *_homeButton;
    AGSpriteButton *_soundButton;
    AGSpriteButton *_replayLevelButton;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.size = [BVSize originalScreenSize];
        self.zPosition = -1;
        
        // create background node
        _background = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0 alpha:0.2] size:self.size];
        _background.name = @"background-node";
        _background.alpha = 0;
        [self addChild:_background];
        
        // create ball back
        _content = [SKSpriteNode spriteNodeWithImageNamed:@"level-menu-back"];
        _content.size = [BVSize sizeOniPhones:CGSizeMake(295, 285) andiPads:CGSizeMake(450, 440)];
        [self addChild:_content];
        
        float contentW = _content.size.width;
        float contentH = _content.size.height;
        
        // add verticle line
        SKSpriteNode *vLine = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1 alpha:0.5] size:CGSizeMake(contentW * 0.7, 1)];
        vLine.zPosition = _content.zPosition+1;
        [_content addChild:vLine];
        
        // add horizontal line
        SKSpriteNode *hLine = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1 alpha:0.5] size:CGSizeMake(1, contentH * 0.7)];
        hLine.zPosition = _content.zPosition+1;
        [_content addChild:hLine];
        
        // setup buttons
        _levelsButton = [AGSpriteButton buttonWithImageNamed:@"level-menu-levels-icon"];
        [_levelsButton addTarget:self selector:@selector(goToLevels) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
        _levelsButton.size = [BVSize sizeOniPhones:CGSizeMake(50, 50) andiPads:CGSizeMake(80, 80)];
        _levelsButton.position = CGPointMake(-(contentW * 0.25) + _levelsButton.size.width/2, (contentH * 0.25) - _levelsButton.size.height/2);
        _levelsButton.zPosition = _content.zPosition+1;
        [_content addChild:_levelsButton];
        
        _homeButton = [AGSpriteButton buttonWithImageNamed:@"level-menu-home-icon"];
        [_homeButton addTarget:self selector:@selector(goToHomepage) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
        _homeButton.size = [BVSize sizeOniPhones:CGSizeMake(50, 50) andiPads:CGSizeMake(80, 80)];
        _homeButton.position = CGPointMake((contentW * 0.25) - _homeButton.size.width/2, _levelsButton.position.y);
        _homeButton.zPosition = _content.zPosition+1;
        [_content addChild:_homeButton];
        
        NSString *soundButtonImg = ([[BVGameData sharedGameData] isSoundOn]) ? @"level-menu-sound-icon" : @"level-menu-sound-mute-icon";
        _soundButton = [AGSpriteButton buttonWithImageNamed:soundButtonImg];
        [_soundButton addTarget:self selector:@selector(toggleSound) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
        _soundButton.size = [BVSize sizeOniPhones:CGSizeMake(50, 50) andiPads:CGSizeMake(80, 80)];
        _soundButton.position = CGPointMake(_levelsButton.position.x, -_levelsButton.position.y);
        _soundButton.zPosition = _content.zPosition+1;
        [_content addChild:_soundButton];
        
        _replayLevelButton = [AGSpriteButton buttonWithImageNamed:@"level-menu-replay-icon"];
        [_replayLevelButton addTarget:self selector:@selector(replayLevel) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
        _replayLevelButton.size = [BVSize sizeOniPhones:CGSizeMake(50, 50) andiPads:CGSizeMake(80, 80)];
        _replayLevelButton.position = CGPointMake(_homeButton.position.x, _soundButton.position.y);
        _replayLevelButton.zPosition = _content.zPosition+1;
        [_content addChild:_replayLevelButton];
        
        [_content setScale:0];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)presentMenu
{
    self.zPosition = 20;
    
    // pause the timer
    _bottomHud.timerPaused = YES;
    
    // animate menu
    [_background runAction:[SKAction fadeInWithDuration:0.2]];
    [_content runAction:[SKAction sequence:@[[SKAction scaleTo:1.1 duration:0.2],
                                         [SKAction scaleTo:0.9 duration:0.1],
                                         [SKAction scaleTo:1 duration:0.1]]]];
    
    // & make it visible
}

- (void)dismissMenu
{
    // re-enable the timer
    _bottomHud.timerPaused = NO;
    
    // animate to dismiss
    __weak BVLevelMenu *weakSelf = self;
    [_background runAction:[SKAction fadeOutWithDuration:0.2]];
    [_content runAction:[SKAction sequence:@[[SKAction scaleTo:1.1 duration:0.1],
                                             [SKAction scaleTo:0.0 duration:0.2],
                                             [SKAction runBlock:^{
        weakSelf.zPosition = -1;
    }]]]];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [[touches anyObject] locationInNode:self];
    
    if ([[self nodeAtPoint:touchLoc].name isEqualToString:@"background-node"]) {
        [self dismissMenu];
    }
}

#pragma mark - Button Handlers

- (void)goToLevels
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    [_level goToLevelsPage];
}

- (void)goToHomepage
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    [_level goToHomepage];
}

- (void)toggleSound
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    BOOL isSoundOn = [[BVGameData sharedGameData] isSoundOn];
    
    // toggle sound
    if (isSoundOn) {
        [[BVGameData sharedGameData] disableSound];
        _soundButton.texture = [SKTexture textureWithImageNamed:@"level-menu-sound-mute-icon"];
        [[BVSounds sharedInstance] stopMusic];
    }
    else {
        [[BVGameData sharedGameData] enableSound];
        _soundButton.texture = [SKTexture textureWithImageNamed:@"level-menu-sound-icon"];
        [[BVSounds sharedInstance] playMusic];
    }
}

- (void)replayLevel
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    [_level restartLevel];
}

#pragma mark - Button Clearup

- (void)removeAllButtonTargets
{
    [_levelsButton removeAllTargets];
    [_homeButton removeAllTargets];
    [_soundButton removeAllTargets];
    [_replayLevelButton removeAllTargets];
}

@end
