//
//  HUD.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/19/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//
#import "BVHud.h"
#import "BVColor.h"
#import "UIImage+Scaling.h"
#import "BVSize.h"
#import "AGSpriteButton.h"
#import "BVTransition.h"
#import "UIImage+Scaling.h"
#import "UIColor+Mix.h"
#import "SKSpriteNode+BVPos.h"
#import "BVUtility.h"
#import "BVLevel.h"
#import "BVSounds.h"

#define percent(percentage, number) ((percentage * number) / 100)

typedef NS_ENUM(NSUInteger, BVHudElement) {
    BVHudElementTarget,
    BVHudElementMoves,
    BVHudElementTimer
};

@implementation BVHud
{
    SKSpriteNode *_target;
    NSMutableArray <BVLabelNode *> *_targetLabelList;
    BVLabelNode *_moves; // only used in bottomHud
    BOOL _isBottomHud;
    CGSize _viewSize; // for reference
    AGSpriteButton *_showLevelMenu;
    AGSpriteButton *_guidePageButton;
    SKShapeNode *_levelTimer;
    SKShapeNode *_levelTimerProgress;
    BVLabelNode *_timeLeftLabel;
    NSTimeInterval _launchTime;
    NSTimeInterval _timerPausedAt;
    CGFloat _elapsedTime;
    int _timerGoal;
}

@synthesize timerPaused = _timerPaused;

#pragma mark - Initializers

+ (nonnull instancetype)topHudOfLevel:(int)levelNum wthTargets:(nonnull NSArray *)targets viewSize:(CGSize)size
{
    return [[BVHud alloc] initWithTarget:targets levelNum:levelNum viewSize:size];
}

+ (nonnull instancetype)bottomHudOfLevel:(int)level withGoalOptions:(NSDictionary *)goalOptions viewSize:(CGSize)size
{
    return [[BVHud alloc] initWithLevel:level withGoalOptions:goalOptions viewSize:size];
}

- (nonnull instancetype)initWithTarget:(nonnull NSArray *)targets levelNum:(int)levelNum viewSize:(CGSize)size
{
    self = [super init];
    
    if (self) {
        
        _viewSize = [BVSize screenSize];
        
        self.name = @"Top Hud";
        self.color = [UIColor clearColor];
        self.size = [BVSize resizeUniversally:[BVSize sizeOniPhones:CGSizeMake(0, 68) andiPads:CGSizeMake(0, 48)] firstTime:YES useFullWidth:YES];
        
        // positive half of screen size gives MaxY pos. eg: (size.height / 2)
        float hudMarginTop = [BVSize scalableMargin:-10 type:BVSizeMarginTypeTop];
        self.position = CGPointMake(0, (size.height / 2) - (self.size.height / 2) + hudMarginTop);
        
        _isBottomHud = NO; // because this method only initializes top hud.
        
        // initialize label list
        _targetLabelList = [NSMutableArray array];
        
        float tFrameH = [BVSize valueOniPhones:47 andiPads:40];
        // Note: _target node's position is set in placeElement: method
        _target = [SKSpriteNode spriteNodeWithColor:[BVColor r:255 g:255 b:255 alpha:0.5] size:[BVSize resizeUniversally:CGSizeMake(0, tFrameH) firstTime:YES]];
        _target.anchorPoint = CGPointMake(0.0, 0.5);
        
        // [BVColor mixEmUp:@[[BVColor redColor], [BVColor violet]]]
        UIColor *primaryColor = [BVColor r:4 g:58 b:78]; // [BVColor r:0 g:84 b:144]
        SKSpriteNode *targetLabelNode = [SKSpriteNode spriteNodeWithColor:primaryColor size:CGSizeMake(0, 0)];
        
        // add label inside targetLabel
        BVLabelNode *targetLabel = [BVLabelNode labelWithText:@"GOAL"];
        targetLabel.fontColor = [BVColor whiteColor];
        targetLabel.fontSize = BVdynamicFontSizeWithFactor(_viewSize, 0.04);
        targetLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [targetLabelNode addChild:targetLabel];
        
        // setup size & position of targetLabelNode
        CGSize targetLabelNodeFrame = [targetLabelNode calculateAccumulatedFrame].size;
        targetLabelNode.size = [BVSize resizeUniversally:CGSizeMake(targetLabelNodeFrame.width + (targetLabelNodeFrame.width * 0.2), targetLabelNodeFrame.height + ( targetLabelNodeFrame.height * 0.2)) firstTime:NO];
        targetLabelNode.position = CGPointMake(targetLabelNode.size.width / 2.5, _target.size.height / 1.8);
        
        [_target addChild:targetLabelNode];
        
        [self createTargets:targets addThemIn:_target storeReference:_targetLabelList];
        
        [self addChild:_target];
        
        // Position all elements
        [self placeElement:BVHudElementTarget];
        
        // menu button
        _showLevelMenu = [AGSpriteButton buttonWithColor:primaryColor andSize:[BVSize resizeUniversally:CGSizeMake(47, tFrameH) firstTime:YES]];
        [_showLevelMenu setLabelWithText:@"MENU" andFont:[UIFont fontWithName:BVdefaultFontName() size:BVdynamicFontSizeWithFactor(_viewSize, 0.044)] withColor:[UIColor whiteColor]];
        _showLevelMenu.position = CGPointMake(CGRectGetMinX(self.frame) + (_showLevelMenu.size.width / 2), _target.position.y);
        [_showLevelMenu addTarget:self selector:@selector(showLevelMenu) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
        [self addChild:_showLevelMenu];
        
        // guide page button
        _guidePageButton = [AGSpriteButton buttonWithImageNamed:@"guide-icon-down"];//buttonWithImageNamed:@"guide-icon-down"
        _guidePageButton.size = [BVSize sizeOniPhone4s:CGSizeMake(22, 22) iPhone5To6sPlus:CGSizeMake(24, 24) iPad:CGSizeMake(38, 38)];
        _guidePageButton.position = CGPointMake(CGRectGetMaxX(_showLevelMenu.frame) + (_guidePageButton.size.width * 2), self.size.height/2 + 1);
        [_guidePageButton addTarget:self selector:@selector(guideButtonHandler) withObject:nil forControlEvent:AGButtonControlEventTouchUpInside];
        
        // add animation to _guidePageButton
        float guideBtnMoveBy = [BVSize valueOniPhones:3 andiPads:10];
        SKAction *guideBtnAnimation = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:guideBtnMoveBy duration:0.5],
                                                                                            [SKAction moveByX:0 y:-(guideBtnMoveBy) duration:0.5]]]];
        [_guidePageButton runAction:guideBtnAnimation];
        [self addChild:_guidePageButton];
        
        // enable touches
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (nonnull instancetype)initWithLevel:(int)levelNum withGoalOptions:(NSDictionary *)goalOptions viewSize:(CGSize)size
{
    self = [super init];
    
    if (self) {
        self.name = @"Bottom Hud";
        self.color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
        self.size = [BVSize resizeUniversally:CGSizeMake(0, 45) firstTime:YES useFullWidth:YES];
        // positive half of screen size gives MaxY pos.
        self.position = CGPointMake(0, -(size.height / 2 - (self.size.height / 2)));
        
        _isBottomHud = YES;
        _viewSize = size;
        
        // extract data from goal options
        NSArray *starPoints = [goalOptions objectForKey:@"starPoints"];
        int moves = [[goalOptions objectForKey:@"moves"] intValue];
        _timerGoal = [[goalOptions objectForKey:@"timer"] intValue];
        
        // Create a tiled texture for the hud background
        //[self setupTiledTexture];
        self.texture = [SKTexture textureWithImage:[[UIImage imageNamed:@"bottom-hud-back-plain"] tiledImageOfSize:self.size]];
        
        _levelRating = [[BVLevelRating alloc] initWithStarPoints:starPoints size:[BVSize resizeUniversally:CGSizeMake(110, 28) firstTime:YES] viewSize:size];
        _levelRating.position = CGPointMake(CGRectGetMaxX(self.frame) - ([_levelRating calculateAccumulatedFrame].size.width / 1.8), 0);
        _levelRating.zPosition = self.zPosition + 1;
        [self addChild:_levelRating];
        
        // add moves label if required by level
        [self setupMovesLabel:moves viewSize:size];
        
        // setup timer when it's required.
        if (_timerGoal) {
            _timerPaused = YES; // pause the timer by default, BVLevel will enable it.
            _noTimeLeft = NO;
            [self setupTimer];
        }
        
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

#pragma mark - HUD Modifiers

- (void)updateTargetLabels:(NSArray *)targets
{
//    [BVHud updateTargets:targets inLabelsList:_targetLabelList enableCrossmarks:NO forceRefresh:NO];
    [self updateTargets:targets];
}

- (void)updateMoves:(int)moves
{
    _moves.text = [NSString stringWithFormat:@"%i", moves];
}

- (void)placeElement:(BVHudElement)element
{
    float hudWidth = self.size.width;
    float hudHeight = self.size.height;
    float targetWidth = CGRectGetWidth(_target.frame);
    float targetHeight = CGRectGetHeight(_target.frame);
    float movesHolderWidth = _movesHolder.size.width;
    float levelTimerWidth = CGRectGetWidth(_levelTimer.frame);
    
    float timerX = CGRectGetMaxX(_movesHolder.frame) + ((CGRectGetMinX(_levelRating.frame) - CGRectGetMaxX(_movesHolder.frame) ) / 2);
    
    switch (element) {
        case BVHudElementTarget:
            _target.position = CGPointMake((hudWidth / 2) - targetWidth, 0);
            break;
            
        case BVHudElementMoves:
            _movesHolder.position = CGPointMake(-((hudWidth / 2) - movesHolderWidth / 1.5), 0);
            break;
            
        case BVHudElementTimer:
            _levelTimer.position = CGPointMake(timerX, 0);//CGPointMake(_movesHolder.position.x + (movesHolderWidth / 2) + (levelTimerWidth / 1.5), 0);
            break;
            
        default:
            break;
    }
}

#pragma mark - Touch Handling
- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    if (self.enableBucketRackScrollingOnTouch) {
        [self.bucketRack touchesBegan:touches withEvent:event];
    }
    
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.enableBucketRackScrollingOnTouch) {
        [self.bucketRack touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.enableBucketRackScrollingOnTouch) {
        [self.bucketRack touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.enableBucketRackScrollingOnTouch) {
        [self.bucketRack touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - Button Handler
- (void)showLevelMenu
{
    // play tap sound
    [self runAction:[BVSounds tap]];

    BVLevel *level = (BVLevel *)self.parent;
    
    [level.menu presentMenu];
    
    
//    UINavigationController *navController = (UINavigationController *)self.scene.view.window.rootViewController;
//    
//    // remove references
//    [self removeButtonTargets];
//    [BVUtility cleanUpChildrenAndRemove:self.scene];
//    [navController popViewControllerAnimated:YES];
    
    //    GameViewController *gameViewController = (GameViewController *)self.scene.view.nextResponder;
//    // let's reset the properties
//    gameViewController.showPlayground = NO;
//    gameViewController.showLevelNum = 0;
//    
//    [self removeButtonTargets];
//    [BVUtility cleanUpChildrenAndRemove:self.scene];
//    
//    [gameViewController performSegueWithIdentifier:@"showLevels" sender:nil];
    
//    BVSelectLevel *selectLevels = [[BVSelectLevel alloc] init];
//    BVTransition *levelsPresenter = [[BVTransition alloc] init];
//    __weak BVHud *weakSelf = self;
//    [levelsPresenter presentNewScene:selectLevels oldScene:self.scene block:^{
//        // we MUST remove all targets, unless it will never let BVHud deallocate from the memory!
//        [weakSelf removeButtonTargets];
//    }];
}

- (void)guideButtonHandler
{
    BVLevel *level = (BVLevel *)self.parent;
    [level showGuidePageViewController];
}

- (void)removeButtonTargets
{
    [_showLevelMenu removeAllTargets];
    _showLevelMenu = nil;
    [_guidePageButton removeAllTargets];
    _guidePageButton = nil;
    //[_levelsPageButton removeTarget:self selector:@selector(showLevels) forControlEvent:AGButtonControlEventTouchUpInside];
}

#pragma mark - Moves Label
- (void)setupMovesLabel:(int)moves viewSize:(CGSize)viewSize
{
    if (moves > -1) {
        viewSize = [BVSize screenSize];
        
        BVLabelNode *movesLabel = [BVLabelNode labelWithText:@"Moves:"];
        movesLabel.fontSize = BVdynamicFontSizeWithFactor(viewSize, 0.05);
        movesLabel.fontColor = [UIColor whiteColor];
        movesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        movesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        
        _moves = [BVLabelNode labelWithText:@""];
        _moves.fontSize = BVdynamicFontSizeWithFactor(viewSize, 0.05);
        _moves.text = [NSString stringWithFormat:@"%i", moves];
        _moves.fontColor = [UIColor whiteColor];
        _moves.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _moves.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;

        _movesHolder = [SKSpriteNode spriteNodeWithImageNamed:@"moves-holder-back"];
        // add childs
        [_movesHolder addChild:movesLabel];
        [_movesHolder addChild:_moves];
        _movesHolder.zPosition = self.zPosition + 1;
        
        // setup positions
        movesLabel.zPosition = 1;
        _moves.position = CGPointMake(CGRectGetMaxX(movesLabel.frame) + 5, 0);
        _moves.zPosition = 1;
        
        CGSize movesHolderFrame = [_movesHolder calculateAccumulatedFrame].size;
        _movesHolder.size = CGSizeMake(movesHolderFrame.width, [BVSize resizeUniversally:CGSizeMake(movesHolderFrame.width, 28) firstTime:YES].height);
        _movesHolder.centerRect = CGRectMake(0.5, 0.1, 0.1, 0.8);
        [_movesHolder setScale:2.0];
        
        // adjust _moveHolders size and it's children scale properties, because we have scaled the size of _movesHolder by 2
        _movesHolder.size = CGSizeMake(_movesHolder.size.width / 2, _movesHolder.size.height / 2);
        [movesLabel setScale:0.5];
        [_moves setScale:0.5];
        
        // reset the positions after adjusting size
        movesLabel.position = CGPointMake(-(_movesHolder.size.width / 4) + 4, 0);
        _moves.position = CGPointMake(CGRectGetMaxX(movesLabel.frame) + 2, 0);
        
        [self placeElement:BVHudElementMoves];
        
        [self addChild:_movesHolder];
    }
}

#pragma mark - Level Timer

- (void)setupTimer
{
    _levelTimer = [SKShapeNode shapeNodeWithCircleOfRadius:(self.size.height / 2.7)];
    _levelTimer.zPosition = self.zPosition + 1;
    _levelTimer.fillColor = [UIColor colorWithRed:80/255.0f green:51/255.0f blue:0/255.0f alpha:1.0];
    _levelTimer.lineWidth = 0.0;
    
    _levelTimerProgress = [SKShapeNode node];
    _levelTimerProgress.lineWidth = (self.size.height / 3.0);
    _levelTimerProgress.antialiased = YES;
    _levelTimerProgress.strokeColor = [BVColor green];
    
    // run animation as time progress
//    [_levelTimerProgress runAction:[SKAction customActionWithDuration:_timerGoal actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
//        
//        
//        
//    }]];
    
    _launchTime = 0;
    
    // reset timer progress
    [self setupTimerProgress:0.0];
    
    [_levelTimer addChild:_levelTimerProgress];
    
    [self placeElement:BVHudElementTimer];
    
    
    // add time left label
    _timeLeftLabel = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%i", _timerGoal]];
    _timeLeftLabel.fontSize = BVdynamicFontSizeWithFactor(_viewSize, 0.05);
    _timeLeftLabel.fontColor = [UIColor whiteColor];
    _timeLeftLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _timeLeftLabel.zPosition = _levelTimer.zPosition + 2;
    _timeLeftLabel.position = _levelTimer.position;
    [self addChild:_timeLeftLabel];
    
    
    [self addChild:_levelTimer];
}

- (void)setupTimerProgress:(float)progress
{
    progress = 1.0f - progress;
    
    CGFloat startAngle = M_PI / 2.0f;
    CGFloat endAngle = startAngle + (progress * 2.0f * M_PI);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:(_levelTimerProgress.lineWidth / 2) startAngle:startAngle endAngle:endAngle clockwise:YES];
    _levelTimerProgress.path = path.CGPath;
}

- (void)timerProgressAnimation:(CGFloat)elapsedTime
{
    float goals25Percent = percent(25, _timerGoal);
    // UIColor at index 0 must match the default color of the timerProgress.
    NSArray *stopColors = @[[BVColor green],
                            [BVColor mixEmUp:@[[BVColor green], [BVColor yellow]]],
                            [BVColor yellow],
                            [BVColor orange],
                            [BVColor red]];
    
    UIColor *prevStopColor;
    UIColor *currentStopColor;
    
    float calcs = elapsedTime / goals25Percent;
    
    int num = 0;
    
    while (calcs >= 1) {
        calcs -= 1;
        num++;
    }
    
    // just make sure that number never get's out of range because we're using it as an index.
    num = (num == stopColors.count) ? ((int)stopColors.count - 1) : num;
    
    prevStopColor = [stopColors objectAtIndex:num];
    
    // make sure if adding 1 to num makes it out of bound then cap it.
    num = ((num + 1) >= stopColors.count) ? ((int)stopColors.count - 1) : num + 1;
    currentStopColor = [stopColors objectAtIndex:num];
    
    _levelTimerProgress.strokeColor = [UIColor colorBetweenColor:prevStopColor andColor:currentStopColor percentage:calcs];
}


- (void)updateTimerProgress:(NSTimeInterval)currentTime
{
    // only progress when there is timer available. (common sense)
    if (_timerGoal && !_timerPaused) {
        
        // only run first time to setup launch time
        if (!_launchTime) {
            _launchTime = CACurrentMediaTime();
        }
        
        _elapsedTime = (currentTime - _launchTime);
        CGFloat progress = _elapsedTime / _timerGoal;
        
        int timeLeft = (_timerGoal - _elapsedTime) + 1;
        timeLeft = (timeLeft < 0) ? 0 : timeLeft; // capping the timeLeft if it's less than 0
        _timeLeftLabel.text = [NSString stringWithFormat:@"%i", timeLeft];
        
        // check if progress have reached it's limit
        if (progress >= 1.0) {
            _elapsedTime = _timerGoal;
            progress = 1;
        }
        
        if (!_noTimeLeft) {
            [self timerProgressAnimation:_elapsedTime];
            [self setupTimerProgress:progress];
        }
        
        // no we're not insane to perform the same if statement again. It does have a meaning.
        // We must set _noTimeLeft = YES only after we have updated the animation and progress.
        if (progress >= 1.0) {
            // Timer ran out of time
            _noTimeLeft = YES;
        }
    }
}

- (void)addTimeToTimer:(NSTimeInterval)time withLabelAt:(CGPoint)labelPos
{
    [self addTimeToTimer:time];
    
    NSString *formattedTime;
    UIColor *timeLabelColor;
    
    if (time < 0) {
        formattedTime = [NSString stringWithFormat:@"%i sec", (int)time];
        timeLabelColor = [BVColor red];
    } else {
        formattedTime = [NSString stringWithFormat:@"+%i sec", (int)time];
        timeLabelColor = [BVColor green];
    }
    
    BVLabelNode *timerLabel = [BVLabelNode notificationLabelWithText:formattedTime color:timeLabelColor size:BVdynamicFontSize(_viewSize) pos:labelPos];
    [self.scene addChild:timerLabel];
}

- (void)addTimeToTimer:(NSTimeInterval)time
{
    NSTimeInterval newTime = _launchTime + time;

    // (_launchTime + _elapsedTime) gives us the point where we started the timer.
    // make sure that newTime is not passing that point. if so, it will make the circle look blue.
    // so down there we're basically capping the value if it's bigger.
    _launchTime = (newTime > (_launchTime + _elapsedTime)) ? _launchTime + _elapsedTime : newTime;
}

#pragma mark - Reset Top Hud -- (NOT USING)

- (void)resetTopHud:(NSArray *)targets
{
    [self resetTargets:targets];
}

- (void)resetTargets:(nonnull NSArray *)targets
{
    int i = 0;
    for (NSDictionary *targetInfo in targets) {
        int target = [[targetInfo objectForKey:@"target"] intValue];
        BVLabelNode *targetLabel = _targetLabelList[i];
        BOOL targetReached = [[targetLabel.userData objectForKey:@"reached"] boolValue];
        
        if (targetReached) {
            // remove any checkmark
            [targetLabel.parent enumerateChildNodesWithName:@"checkmark" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                [BVUtility cleanUpChildrenAndRemove:node];
            }];
            
            // make the target label visible again
            targetLabel.hidden = NO;
            
            // reset the reached value
            [targetLabel.userData setObject:@NO forKey:@"reached"];
        }
        
        targetLabel.text = [NSString stringWithFormat:@"%i", target];
        
        i++;
    }
}

#pragma mark - Reset Bottom Hud --- (NOT USING)

- (void)resetBottomHud:(NSDictionary *)goalOptions
{
    // extract data from goal options
    int moves = [[goalOptions objectForKey:@"moves"] intValue];
    
    // reset moves
    [self updateMoves:moves];
    // reset timer (this method first checks if timer available)
    [self resetTimer];
    // reset ratings
    [_levelRating resetRatings];
}

- (void)resetTimer
{
    if (_timerGoal) {
        _noTimeLeft = NO;
        _launchTime = 0;
        // reset timer progress
        [self setupTimerProgress:0.0];
    }
}

#pragma mark - Getter & Setter

- (void)setTimerPaused:(BOOL)timerPaused
{
    // if timer is already paused, and we try to re-enable it
    if (_timerPaused == YES && timerPaused == NO) {
        _launchTime += (CACurrentMediaTime() - _timerPausedAt);
    }
    else if (_timerPaused == NO && timerPaused == YES) {
        _timerPausedAt = CACurrentMediaTime();
    }
    
    _timerPaused = timerPaused;
}

#pragma mark - Utility Methods

- (void)createTargets:(NSArray *)targets addThemIn:(SKSpriteNode *)targetHolderNode storeReference:(NSMutableArray <BVLabelNode *> *)refArr
{
    SKSpriteNode *prevTarget = [SKSpriteNode node];
    CGSize targetSize = [BVSize resizeUniversally:[BVSize sizeOniPhones:CGSizeMake(24, 30) andiPads:CGSizeMake(20, 26)] firstTime:YES];
    float labelFontSize = BVdynamicFontSizeWithFactor(_viewSize, 0.06);
    float targetWidth  = 0.0;
    float targetMargin = 0.0;
    
    for (NSDictionary *targetInfo in targets) {
        int targetCount = [[targetInfo objectForKey:@"target"] intValue];
        
        BVLabelNode *label = [BVLabelNode labelWithText:[NSString stringWithFormat:@"%i", targetCount]];
        label.fontSize = labelFontSize;
        label.fontColor = [UIColor whiteColor];
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        label.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"reached": @NO}];
        
        // save the labe in refArr
        [refArr addObject:label];
        
        // Create target bucket and position it
        SKSpriteNode *target = [SKSpriteNode spriteNodeWithColor:[targetInfo objectForKey:@"targetColor"] size:targetSize];
        
        targetWidth = targetSize.width;
        float targetHeight = targetSize.height;
        targetMargin = ((targetHolderNode.size.height - targetHeight) / 2);
        
        if (CGPointEqualToPoint(prevTarget.position, CGPointZero)) {
            // this is first target
            target.position = CGPointMake((targetWidth / 2) + targetMargin, 0);
        }
        else {
            target.position = CGPointMake((prevTarget.position.x + prevTarget.size.width/2) + targetMargin + (target.size.width/2), 0);
        }
        
        prevTarget = target;
        
        // add target label
        [target addChild:label];
        
        // add target cover
        SKSpriteNode *targetCover = [SKSpriteNode spriteNodeWithImageNamed:@"bucket-cover"];
        targetCover.size = target.size;
        [target addChild:targetCover];
        
        [targetHolderNode addChild:target];
    }
    
    int totalTargets = [targets count];
    targetHolderNode.size = CGSizeMake((totalTargets * targetWidth) + (totalTargets * targetMargin) + targetMargin, targetHolderNode.size.height);
}

- (void)updateTargets:(NSArray *)targets
{
    int i = 0;
    for (NSDictionary *targetInfo in targets) {
        int target = [[targetInfo objectForKey:@"target"] intValue];
        int hitCount = [[targetInfo objectForKey:@"hit"] intValue];
        BVLabelNode *currentLabel = _targetLabelList[i];
        BOOL targetReached = [[currentLabel.userData objectForKey:@"reached"] boolValue];
        
        if (!targetReached && target != hitCount) {
            currentLabel.text = [NSString stringWithFormat:@"%i", target - hitCount];
        }
        else if (!targetReached && target == hitCount) {
            // mark this target as reached
            [currentLabel.userData setObject:@YES forKey:@"reached"];
            
            // hide the label
            currentLabel.hidden = YES;
            SKSpriteNode *targetNode = (SKSpriteNode *)currentLabel.parent;
            
            // present white checkmark in the middle
            SKAction *decisionAnimation = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:0.2],
                                                               [SKAction scaleTo:1.0 duration:0.1]]];
            
            // Add checkmark animation for hitting bucket's target
            SKSpriteNode *checkmark = [SKSpriteNode spriteNodeWithImageNamed:@"tick"];
            checkmark.name = @"checkmark";
            checkmark.position = CGPointZero;
            checkmark.size = [BVSize resizeUniversally:CGSizeMake(16.5, 10) firstTime:YES];
            [checkmark setScale:0.0];
            [targetNode addChild:checkmark];
            
            // run the animation
            [checkmark runAction:decisionAnimation];
        }
        
        i++;
    }
}
@end
