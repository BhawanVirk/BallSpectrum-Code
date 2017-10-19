//
//  GameScene.m
//  Balls
//
//  Created by Bhawan Virk on 6/12/15.
//  Copyright (c) 2015 Bhawan Virk. All rights reserved.
//

@import GameKit;
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKShareKit/FBSDKShareKit.h>
#import "MainScene.h"
#import "AGSpriteButton.h"
#import "BVColor.h"
#import "SKSpriteNode+BVPos.h"
#import "BVLabelNode.h"
#import "BVSize.h"
#import "UIImage+Scaling.h"
#import "BVUtility.h"
#import "MainViewController.h"
#import "BVTransition.h"
#import "UIImage+Scaling.h"
#import "BVGameData.h"
#import "BVInAppPurchaseDialog.h"
#import "BVRollingThings.h"
#import "BVSounds.h"

typedef NS_OPTIONS(NSUInteger, BVBackgroundPhysics) {
    BVBackgroundPhysicsWall = 0x1 << 0,
    BVBackgroundPhysicsBlurBall = 0x1 << 1
};

static const CGFloat kMinFPS = 10.0 / 60.0;
static const int TOTAL_BLUR_BALLS = 6;

@interface MainScene () <GKGameCenterControllerDelegate>

@end

@implementation MainScene
{
    AGSpriteButton *_goToPlayground;
    AGSpriteButton *_goToLevels;
    AGSpriteButton *_goToRecentLevel;
    AGSpriteButton *_coinsStoreButton;
    AGSpriteButton *_removeAdsButton;
    AGSpriteButton *_gameCenterButton;
    AGSpriteButton *_soundButton;
    AGSpriteButton *_shareButton;
    BVRollingThings *_rollingThings;
}

- (void)didMoveToView:(SKView *)view {

    /* Setup your scene here */
    self.size = [BVSize originalScreenSize];
    self.scaleMode = SKSceneScaleModeResizeFill;
    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.backgroundColor = [BVColor r:137 g:226 b:255];//[UIColor whiteColor];
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    _rollingThings = [[BVRollingThings alloc] init];
    _rollingThings.parentNode = self;
    
    // add content
    [self addContent];
    
    CGSize resizableBigButtonSize = [BVSize resizeUniversally:CGSizeMake(150, 67.5) firstTime:YES];
    CGSize resizableSmallButtonSize = [BVSize resizeUniversally:CGSizeMake(65, 67.5) firstTime:YES];
    
    CGSize bigButtonSize = [BVSize sizeOniPhones:resizableBigButtonSize andiPads:CGSizeMake(210, 95)];
    CGSize smallButtonSize = [BVSize sizeOniPhones:resizableSmallButtonSize andiPads:CGSizeMake(92, 95)];
    float buttonFontSize = [BVSize valueOniPhones:22 andiPads:30];
    float buttonsWrapperMargin = [BVSize valueOniPhones:20 andiPads:45];
    CGSize buttonsWrapperSize = CGSizeMake([BVSize valueOniPhones:255 andiPads:385], (bigButtonSize.height * 2) + buttonsWrapperMargin*3);
    
#warning Take care of this wrapper because we don't have any visual appearance for it
//    SKSpriteNode *buttonsWrapper = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"home-stripe-background"] size:buttonsWrapperSize];
    SKShapeNode *buttonsWrapper = [SKShapeNode node];
    buttonsWrapper.path = CGPathCreateWithRoundedRect(CGRectMake(-buttonsWrapperSize.width/2, -buttonsWrapperSize.height/2, buttonsWrapperSize.width, buttonsWrapperSize.height), 5, 5, nil);
    buttonsWrapper.strokeColor = [UIColor clearColor];//[UIColor colorWithWhite:1 alpha:0.5];
    buttonsWrapper.fillColor = [UIColor clearColor];//[UIColor colorWithWhite:1 alpha:0.2];
    buttonsWrapper.position = CGPointMake(0, 0);
    
    SKAction *scaleAnimationBig = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.05 duration:1],
                                                                                     [SKAction scaleTo:1.0 duration:1]]]];
    
    SKAction *scaleAnimationSmall = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.05 duration:0.5],
                                                                                       [SKAction scaleTo:1.0 duration:0.5]]]];
    
    // Play Button
    SKTexture *goToRecentTexture = [SKTexture textureWithImageNamed:@"home-play-button"];
    _goToRecentLevel = [AGSpriteButton buttonWithTexture:goToRecentTexture andSize:bigButtonSize];
    _goToRecentLevel.position = CGPointMake(0, CGRectGetMaxY(buttonsWrapper.frame) - bigButtonSize.height/2 - buttonsWrapperMargin);
    [_goToRecentLevel addTarget:self selector:@selector(goToRecentLevel) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [_goToRecentLevel runAction:scaleAnimationBig];
    [buttonsWrapper addChild:_goToRecentLevel];
    
    // Infinite Land Button
    SKTexture *goToPlaygroundTexture = [SKTexture textureWithImageNamed:@"home-infinity-land-button"];
    _goToPlayground = [AGSpriteButton buttonWithTexture:goToPlaygroundTexture andSize:smallButtonSize];
    _goToPlayground.position = CGPointMake(CGRectGetMaxX(_goToRecentLevel.frame) - (smallButtonSize.width/2), CGRectGetMinY(_goToRecentLevel.frame) - (smallButtonSize.height/2) - buttonsWrapperMargin/2);
    [_goToPlayground addTarget:self selector:@selector(goToPlayground) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
//    [_goToPlayground runAction:scaleAnimationSmall];
    [buttonsWrapper addChild:_goToPlayground];
    
    // Levels Button
    SKTexture *goToLevelsTexture = [SKTexture textureWithImageNamed:@"home-levels-button"];
    _goToLevels = [AGSpriteButton buttonWithTexture:goToLevelsTexture andSize:smallButtonSize];
    _goToLevels.position = CGPointMake(CGRectGetMinX(_goToRecentLevel.frame) + (smallButtonSize.width/2), _goToPlayground.position.y);
    [_goToLevels addTarget:self selector:@selector(goToLevels) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
//    [_goToLevels runAction:scaleAnimationSmall];
    [buttonsWrapper addChild:_goToLevels];

    [self addChild:buttonsWrapper];
    
    // setup bottom bar
    [self createBottomBar];
}

#pragma mark - Content

- (void)addContent
{
    // add background
    [self addBackground];
    
    // add logo
    CGSize logoImgSize = [BVSize sizeOniPhones:CGSizeMake(300, 500) andiPads:CGSizeMake(600, 500)];
    UIImage *logoImg = [[UIImage imageNamed:@"main-logo"] imageScaledToFitSize:logoImgSize];
    SKSpriteNode *logo = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:logoImg]];
    logo.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - logoImg.size.height);
    
    [BVSize outputSize:logo.size msg:@"logo.size"];
    
    // add moving animation to logo
    SKAction *logoAnimation = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:15 duration:1],
                                                                                 [SKAction moveByX:0 y:-15 duration:1]]]];
    
    [logo runAction:logoAnimation];
    [self addChild:logo];
}

- (void)addBackground
{
    [_rollingThings addClouds];
    
    // add grass background
    SKSpriteNode *grass = [_rollingThings grass];
    grass.size = [BVSize sizeOniPhones:CGSizeMake(415, 195) andiPads:CGSizeMake(768, 300)];
    grass.position = CGPointMake(0, CGRectGetMinY(self.frame) + (grass.size.height/2));
    grass.zPosition = 8;
    [self addChild:grass];
    
    [_rollingThings addGrassyGround];
    // add collision walls for blur balls
    SKSpriteNode *collisionWalls = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.size];
    collisionWalls.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    collisionWalls.physicsBody.categoryBitMask = BVBackgroundPhysicsWall;
    collisionWalls.physicsBody.affectedByGravity = NO;
    collisionWalls.physicsBody.friction = 0.0;
    collisionWalls.physicsBody.linearDamping = 0.0f;
    
    [self addChild:collisionWalls];
    
    CGRect sceneFrame = collisionWalls.frame;
    NSArray *blurBallPositions = @[[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(sceneFrame) + 50, CGRectGetMaxY(sceneFrame) - 50)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(sceneFrame) - 50, CGRectGetMaxY(sceneFrame) - 70)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(sceneFrame) + 60, CGRectGetMidY(sceneFrame))],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(sceneFrame) + 50, CGRectGetMidY(sceneFrame) + 50)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(sceneFrame) + 100, CGRectGetMinY(sceneFrame) + 120)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(sceneFrame) - 80, CGRectGetMinY(sceneFrame) + 100)]];
    
    
    
    // add all of the blurry balls on screen
    for (int i=1; i<=TOTAL_BLUR_BALLS; i++) {
        SKSpriteNode *blurBall = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"blur-ball-%i", i]];
        blurBall.alpha = 0.5;
        blurBall.size = [BVSize resizeUniversally:CGSizeMake(125, 125) firstTime:YES];
        blurBall.position = [blurBallPositions[i-1] CGPointValue];
        [collisionWalls addChild:blurBall];
        
        // give physics body
        blurBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:blurBall.size.width/4];
        blurBall.physicsBody.categoryBitMask = BVBackgroundPhysicsBlurBall;
        blurBall.physicsBody.collisionBitMask = BVBackgroundPhysicsBlurBall | BVBackgroundPhysicsWall;
        blurBall.physicsBody.friction = 0.0f;
        blurBall.physicsBody.restitution = 1.0f;
        blurBall.physicsBody.linearDamping = 0.0f;
        blurBall.physicsBody.allowsRotation = NO;
        blurBall.physicsBody.mass = 0.136354;
        
        NSLog(@"blurBall's mass: %f", blurBall.physicsBody.mass);
        
        // apply impulse
        [blurBall.physicsBody applyImpulse:CGVectorMake(10, -20)];
    }
//
//    // then add tint color sprite layer with 50% opacity // [BVColor r:168 g:231 b:255 alpha:0.5]
//    SKSpriteNode *tintCover = [SKSpriteNode spriteNodeWithColor:[BVColor r:168 g:231 b:255 alpha:0.2] size:self.view.frame.size];
//    [self addChild:tintCover];
}

- (void)createBottomBar
{
    CGSize viewSize = [BVSize originalScreenSize];
    
    float grassyGroundMaxY = CGRectGetMaxY(((SKSpriteNode *)_rollingThings.groundTextures[0]).frame);
    CGSize bottomBarSize = CGSizeMake(viewSize.width * 0.9, [BVSize valueOniPhones:35 andiPads:50]);
    CGPoint bottomBarPos = CGPointMake(0, grassyGroundMaxY + bottomBarSize.height/2);
    UIBezierPath *bottomBarShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-bottomBarSize.width/2, -bottomBarSize.height/2, bottomBarSize.width, bottomBarSize.height) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    SKShapeNode *bottomBar = [SKShapeNode node];
    bottomBar.zPosition = 10;
    bottomBar.path = bottomBarShape.CGPath;
    bottomBar.fillColor = [UIColor clearColor];//[UIColor colorWithWhite:1 alpha:0.5];
    bottomBar.strokeColor = [UIColor clearColor];//[UIColor whiteColor];
    bottomBar.position = bottomBarPos;
    [self addChild:bottomBar];
    
    CGSize buttonSize = [BVSize sizeOniPhones:CGSizeMake(35, 35) andiPads:CGSizeMake(50, 50)];
    float buttonMargin = [BVSize valueOniPhones:15 andiPads:20];
    
    SKSpriteNode *buttons = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeZero];
    buttons.anchorPoint = CGPointMake(0, 0.5);
    // add buttons
    
    /*
     [SKAction repeatActionForever:[SKAction sequence:@[[SKAction rotateToAngle:1 duration:1],
     [SKAction rotateToAngle:-1 duration:1]]]]
     */
    SKAction *rotatingAction = [SKAction repeatActionForever:[SKAction rotateByAngle:-2 duration:0.5]];
    
    // (1) COINS STORE
    _coinsStoreButton = [AGSpriteButton buttonWithTexture:[SKTexture textureWithImageNamed:@"home-bottom-bar-coins-store"] andSize:buttonSize];
    _coinsStoreButton.position = CGPointMake(buttonSize.width/2, 0);
    [_coinsStoreButton addTarget:self selector:@selector(showCoinsStore) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [_coinsStoreButton runAction:rotatingAction];
    [buttons addChild:_coinsStoreButton];
    
    // (2) REMOVE ADS
    _removeAdsButton = [AGSpriteButton buttonWithTexture:[SKTexture textureWithImageNamed:@"home-bottom-bar-remove-ads"] andSize:buttonSize];
    [_removeAdsButton setPosRelativeTo:_coinsStoreButton.frame side:BVPosSideRight margin:buttonMargin setOtherValue:0 scalableMargin:NO];
    [_removeAdsButton addTarget:self selector:@selector(showRemoveAdsDialog) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [_removeAdsButton runAction:rotatingAction];
    [buttons addChild:_removeAdsButton];
    
    // (3) GAME CENTER
    _gameCenterButton = [AGSpriteButton buttonWithTexture:[SKTexture textureWithImageNamed:@"home-bottom-bar-gamecenter"] andSize:buttonSize];
    [_gameCenterButton setPosRelativeTo:_removeAdsButton.frame side:BVPosSideRight margin:buttonMargin setOtherValue:0 scalableMargin:NO];
    [_gameCenterButton addTarget:self selector:@selector(showGameCenter) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [_gameCenterButton runAction:rotatingAction];
    [buttons addChild:_gameCenterButton];
    
    // (4) SOUND
    NSString *soundTexture = ([[BVGameData sharedGameData] isSoundOn]) ? @"home-bottom-bar-sound" : @"home-bottom-bar-sound-mute";
    _soundButton = [AGSpriteButton buttonWithTexture:[SKTexture textureWithImageNamed:soundTexture] andSize:buttonSize];
    [_soundButton setPosRelativeTo:_gameCenterButton.frame side:BVPosSideRight margin:buttonMargin setOtherValue:0 scalableMargin:NO];
    [_soundButton addTarget:self selector:@selector(setGameSound) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [_soundButton runAction:rotatingAction];
    [buttons addChild:_soundButton];
    
    // (5) FB
    _shareButton = [AGSpriteButton buttonWithTexture:[SKTexture textureWithImageNamed:@"home-bottom-bar-share"] andSize:buttonSize];
    [_shareButton setPosRelativeTo:_soundButton.frame side:BVPosSideRight margin:buttonMargin setOtherValue:0 scalableMargin:NO];
    [_shareButton addTarget:self selector:@selector(showShareVC) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
    [_shareButton runAction:rotatingAction];
    [buttons addChild:_shareButton];
    
    // calculate buttons node size
    buttons.size = [buttons calculateAccumulatedFrame].size;
    buttons.position = CGPointMake(CGRectGetMidX(bottomBar.frame) - buttons.size.width/2, 0);
    [bottomBar addChild:buttons];
}

#pragma mark - Transition Methods

- (void)goToRecentLevel
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    MainViewController *mainVC = [self doCleanUpAndGiveMainViewController];
    [mainVC goToRecentLevel];
}

- (void)goToPlayground
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    MainViewController *mainVC = [self doCleanUpAndGiveMainViewController];
    [mainVC goToPlayground];
}

- (void)goToLevels
{
    // play tap sound
    [self runAction:[BVSounds tap]];
    
    MainViewController *mainVC = [self doCleanUpAndGiveMainViewController];
    [mainVC goToLevels];
}

- (MainViewController *)doCleanUpAndGiveMainViewController
{
    [self removeAllButtonTargets];
    
    [BVUtility cleanUpChildrenAndRemove:self];
    
    UINavigationController *nav = ((UINavigationController *)self.view.window.rootViewController);
    MainViewController *mainVC = (MainViewController *)nav.visibleViewController;
    
    return mainVC;
}

#pragma mark - Game Center Authentication

- (void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            UIViewController *vc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
            [vc presentViewController:viewController animated:YES completion:nil];
        }
    };
}

#pragma mark - GKGameCenterControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Bottom Bar Button Actions

- (void)showCoinsStore
{
//    NSLog(@"Open Coins Store Now");
    // play button sound
    [self runAction:[BVSounds tap]];
    
    BVInAppPurchaseDialog *coinsStoreDialog = [[BVInAppPurchaseDialog alloc] initWithPurchaseType:BVInAppPurchaseTypeCoins];

    KLCPopup *popup = [KLCPopup popupWithContentView:coinsStoreDialog showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    coinsStoreDialog.popup = popup;
    [popup show];
}

- (void)showRemoveAdsDialog
{
//    NSLog(@"Remove ads?");
    
    // play button sound
    [self runAction:[BVSounds tap]];
    
    // only show an option to buy this package if ads are still on
    if ([[BVGameData sharedGameData] shouldDisplayAds]) {
        BVInAppPurchaseDialog *removeAdsDialog = [[BVInAppPurchaseDialog alloc] initWithPurchaseType:BVInAppPurchaseTypeAds];
        
        KLCPopup *popup = [KLCPopup popupWithContentView:removeAdsDialog showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
        removeAdsDialog.popup = popup;
        [popup show];
    }
    else {
        // just show a popup that users have already purchased this package
        [BVUtility alertWithTitle:@"Oops" message:@"You're already ad free :)" size:CGSizeZero];
    }
}

- (void)showGameCenter
{
    // play button sound
    [self runAction:[BVSounds tap]];
    
//    [BVUtility alertWithTitle:@"Game Center" message:@"coming soon..." size:CGSizeZero];
//    NSLog(@"show game center ui");
    
    // only display game center dialog if player is signed in
    if ([GKLocalPlayer localPlayer].authenticated) {
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            gameCenterController.leaderboardTimeScope = GKLeaderboardTimeScopeToday;
            gameCenterController.leaderboardIdentifier = @"infinity_land";
            //        gameCenterController.leaderboardCategory = leaderboardID;
            
            UIViewController *vc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
            
            [vc presentViewController:gameCenterController animated:YES completion:nil];
        }
    }
    else {
        // authenticate the player first
        [self authenticateLocalPlayer];
    }
}

- (void)setGameSound
{
    // play button sound
    [self runAction:[BVSounds tap]];
    
    BOOL isSoundOn = [[BVGameData sharedGameData] isSoundOn];
    
    // toggle sound
    if (isSoundOn) {
        [[BVGameData sharedGameData] disableSound];
        _soundButton.texture = [SKTexture textureWithImageNamed:@"home-bottom-bar-sound-mute"];
        [[BVSounds sharedInstance] stopMusic];
    }
    else {
        [[BVGameData sharedGameData] enableSound];
        _soundButton.texture = [SKTexture textureWithImageNamed:@"home-bottom-bar-sound"];
        [[BVSounds sharedInstance] playMusic];
    }
}

- (void)showShareVC
{
    // play button sound
    [self runAction:[BVSounds tap]];
    
//    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
//    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1501718936804520"];
//    //optionally set previewImageURL
//    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://scontent-sea1-1.xx.fbcdn.net/hphotos-xap1/t31.0-8/12698518_1036131433112243_1090267759444317761_o.png"];
//    
//    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
//    UIViewController *vc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
//    [FBSDKAppInviteDialog showFromViewController:vc withContent:content delegate:self];
    UIImage *viewImg = [BVUtility takeScreenshotOfView:self.view];
    NSURL *appUrl = [NSURL URLWithString:@"https://itunes.apple.com/app/ballspectrum/id1076067844"];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[@"Check this game out. You just have to drop matching balls in given pipes. It's that simple. Is it?", viewImg, appUrl] applicationActivities:nil];
    UIViewController *vc = ((UINavigationController *)self.view.window.rootViewController).visibleViewController;
    [vc presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Button Helpers

- (void)removeAllButtonTargets
{
    [_goToLevels removeAllTargets];
    [_goToPlayground removeAllTargets];
    _goToLevels = nil;
    _goToPlayground = nil;
}

#pragma mark - Update Loop

- (void)update:(NSTimeInterval)currentTime
{
    static NSTimeInterval lastCallTime;
    NSTimeInterval timeElapsed = currentTime - lastCallTime;
    if (timeElapsed > kMinFPS) {
        timeElapsed = kMinFPS;
    }
    lastCallTime = currentTime;
    
    [_rollingThings rollBigClouds:timeElapsed];
    [_rollingThings rollSmallClouds:timeElapsed];
    [_rollingThings rollGround:timeElapsed];
}

@end
