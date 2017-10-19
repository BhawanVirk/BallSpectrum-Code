//
//  BallsRack.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 6/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//
#import "BVRackGenerator.h"
#import "SDiPhoneVersion.h"
#import "BVSize.h"
#import "SKSpriteNode+BVPos.h"
#import "BVColor.h"
#import "BVUtility.h"

@interface BVRackGenerator ()

@property (nonatomic, readonly, assign) float leftEndInView;
@property (nonatomic, readonly, assign) float rightEndInView;
@property (nonatomic, readonly, assign) float leftViewEndInScene;
@property (nonatomic, readonly, assign) float rightViewEndInScene;

@end

@implementation BVRackGenerator
{
    float _touchMoveX;
    float _ballPadding;
    CGPoint _initialTouch;
    SKSpriteNode *_ballsFrame;
    SKSpriteNode *_bucketsFrame;
    SKSpriteNode *_rackBar;
    NSMutableArray *_ballHolders;
    NSMutableArray *_ballAdderQueue;
    NSMutableArray<BVBall *> *_ballsThatHitBallDestroyerWhileAnimatingHolders;
}

@synthesize leftEndInView = _leftEndInView;
@synthesize rightEndInView = _rightEndInView;
@synthesize leftViewEndInScene = _leftViewEndInScene;
@synthesize rightViewEndInScene = _rightViewEndInScene;

#pragma mark - Initializers

- (nonnull instancetype)initWithBalls:(nonnull NSArray *)balls
{
    self = [super init];
    
    if (self) {
        self.name = @"BallsRack";
        // view height * 0.4 takes care of devices with different screen sizes
        //self.size = [BVSize resizeUniversally:CGSizeMake(0, 100) firstTime:YES useFullWidth:YES];
        //self.color = [UIColor colorWithWhite:0.5 alpha:0.5];
        //self.position = CGPointMake(0, self.size.height / 2);
        self.anchorPoint = CGPointMake(0.5, 0);
        self.userInteractionEnabled = YES;
        
        // Enable scrolling by default
        _isScrollingPaused = NO;
        
        _ballsList = [NSMutableArray arrayWithArray:balls];
        _ballAdderQueue = [NSMutableArray array];
        _ballsThatHitBallDestroyerWhileAnimatingHolders = [NSMutableArray array];
        
        // Fit'em in
        [self presentBallsOnRack];
    }
    
    return self;
}

- (nonnull instancetype)initWithBuckets:(nonnull NSArray *)buckets bottomMargin:(float)bottomMargin
{
    self = [super init];
    
    if (self) {
        CGSize viewSize = [BVSize originalScreenSize];
        float rackHeight = viewSize.height * 0.15;
        
        self.name = @"BucketsRack";
        self.position = CGPointMake(0, -((viewSize.height - rackHeight) / 2) + bottomMargin);
        self.size = CGSizeMake(viewSize.width, rackHeight);
        
        // Enable scrolling by default
        _isScrollingPaused = NO;
        
        _bucketsList = [NSMutableArray arrayWithArray:buckets];
        
        [self addBucketsToRack];
    }
    
    return self;
}

#pragma mark - Buckets Rack Methods
- (void)addBucketsToRack
{
    _bucketsFrame = [SKSpriteNode node];
    BVBucket *previousBucket;
    float dummyBallWidth = [BVBall solidRed].size.width;
    CGSize bucketSize = [BVBucket bucketColored:[BVColor red] withAddons:nil].size; // store bucket size
    float viewWidth = [BVSize originalScreenSize].width;
    float bucketPadding = [BVSize valueOniPhone4s:(dummyBallWidth * 1.5) + 5 iPhone5To6sPlus:dummyBallWidth + 5 iPad:(dummyBallWidth * 1.4) + 5];
    float yPosOfBucket = -(self.size.height - bucketSize.height) / 2; // this will make the bucket's bottom touch rack's bottom
    
    // put buckets in a frame
    int bucketId = 0;
    for (BVBucket *bucket in _bucketsList) {
        
        // save bucket id
        [bucket.userData setObject:@(bucketId) forKey:@"bucketIdInList"];
        
        // setup position
        if (previousBucket) {
            bucket.position = CGPointMake(previousBucket.position.x + bucket.size.width + bucketPadding, yPosOfBucket);
        }
        else {
            // in case we are dealing with first bucket
            bucket.position = CGPointMake(0, yPosOfBucket);
        }
        
        // setup bucket's zPosition
        bucket.zPosition = 5.0; // bucket zPosition needs to be 2 points ahead of ball's because ball uses cover on it.
        
        // set the current bucket to previousbucket variable, as we're going to use it for next bucket
        previousBucket = bucket;
        
        // add the bucket to bucketsFrame
        [_bucketsFrame addChild:bucket];
        bucketId++;
    }
    
    // calculate the size of bucketsFrame
    CGSize bucketsFrameSize = [_bucketsFrame calculateAccumulatedFrame].size;

    // 
    if (bucketsFrameSize.width < viewWidth) {
        self.userInteractionEnabled = NO;
        _isScrollingPaused = YES;
    }
    else {
        self.userInteractionEnabled = YES;
        _isScrollingPaused = NO;
    }
    
    // update the rack's width
    float newWidth = bucketsFrameSize.width  + ((viewWidth - (bucketSize.width + bucketPadding)) * 2);
    self.size = CGSizeMake(newWidth, self.size.height);
    
    // set bucketsFrame position
    float bucketsFramePosX = CGRectGetMidX(self.frame) - (bucketsFrameSize.width / 2) + (bucketSize.width / 2);
    _bucketsFrame.position = CGPointMake(bucketsFramePosX, _bucketsFrame.position.y);
    
    // finally add bucketsFrame to rack
    [self addChild:_bucketsFrame];
}

- (CGPoint)bucketPosInRack:(BVBucket *)bucket
{
    return [_bucketsFrame convertPoint:bucket.position toNode:self];
}

#pragma mark - Balls Rack Methods

- (void)presentBallsOnRack
{
    _ballsFrame = [SKSpriteNode node];
    _ballsFrame.anchorPoint = CGPointMake(0, 0.5);
    _ballHolders = [NSMutableArray array];
    BVBall *previousBall;
    CGSize ballSize = [BVBall dummyBall].size;
    float viewWidth = [BVSize originalScreenSize].width;
    float ballPaddingMultiplier = [BVSize resizeUniversally:CGSizeMake(0.4, 0.4) firstTime:YES].width; // this works on iphone 5 - 6 plus
    // we'll use this variable to setup Y position of rackBar
    float rackBarY = 0.0;
    float rackBarHeight = [BVSize resizeUniversally:CGSizeMake(4.0, 4.0) firstTime:YES].width; // this works on iphone 5 - 6 plus
    int ballId = 0;
    
    // Calculate the yPosOfBall based on the current height of the rack because rack size varies on different devices with different screen sizes
    float yPosOfBall = (ballSize.height / 2);//-((self.size.height / 2) - (ballSize.height / 2));
    
    if ([SDiPhoneVersion deviceSize] == UnknowniPad) {
        // for all ipad's
        ballPaddingMultiplier = 0.7;
        rackBarHeight = 6.0;
    }
    else if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        // for iphone 4s
        ballPaddingMultiplier = 0.7;
        rackBarHeight = 3.0;
        //yPosOfBall = -((self.size.height / 1.7) - (ballSize.height / 2));
    }
    
    _ballPadding = ballSize.width * ballPaddingMultiplier;
    
    // put balls in a frame
    for (BVBall *ball in _ballsList) {
        
        // ball will save rack as a reference to run it's touch functionality.
        ball.rack = self;
        
        // setup position
        if (previousBall) {
            [ball setPosRelativeTo:previousBall.frame side:BVPosSideRight margin:_ballPadding setOtherValue:previousBall.position.y scalableMargin:NO];
        }
        else {
            // in case we are dealing with first ball
            ball.position = CGPointMake(0, yPosOfBall);
        }
        
        // setup ball's zPosition
        ball.zPosition = 3.0;
        ball.indexInBallsList = ballId;
        
        // set the current ball to previousBall variable, as we're going to use it for next ball
        previousBall = ball;
        
        // lets add ball holder for this ball
        SKSpriteNode *ballHolder = [self createBallHolderFor:ball];

        // We need to access ball's holder in some methods.
        // So we can use ball's index from it's userData to access it's holder from _ballsHolder array
        [_ballHolders addObject:ballHolder];
        [_ballsFrame addChild:ballHolder];
        
        // setup ball
        rackBarY = (!rackBarY) ? CGRectGetMaxY(ballHolder.frame) : rackBarY;
        
        // add the ball to ballsFrame
        [_ballsFrame addChild:ball];
        
        ballId++;
    }
    
    // calculate the size of ballsFrame
    CGSize ballsFrameSize = [_ballsFrame calculateAccumulatedFrame].size;
    _ballsFrame.size = ballsFrameSize;
    
    // update the rack's width
    float newWidth = ballsFrameSize.width + ((viewWidth - (ballSize.width + _ballPadding)) * 2);
    self.size = CGSizeMake(newWidth, ballsFrameSize.height);
    
    // add rack bar
    if (!_rackBar) {
        _rackBar = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width * 1.5, rackBarHeight)];
        _rackBar.position = CGPointMake(self.position.x, rackBarY - _rackBar.size.height);
        _rackBar.color = [UIColor colorWithRed:252.0/255.0
                                         green:194.0/255.0 blue:0 alpha:1.0];
        _rackBar.zPosition = 2.0;
        [self addChild:_rackBar];
    }
    
    // set ballsFrame position
    float ballsFramePosX = CGRectGetMidX(self.frame) - (ballsFrameSize.width / 2) + (ballSize.width / 2);
    _ballsFrame.position = CGPointMake(ballsFramePosX, _ballsFrame.position.y);
    
    // finally add ballsFrame to rack
    [self addChild:_ballsFrame];
}

- (void)addBalls:(NSArray *)ballsList
{
    [_ballAdderQueue addObject:ballsList];
    [self pushBallsQueueOnRack];
}

- (void)pushBallsQueueOnRack
{
    NSArray *balls = [_ballAdderQueue firstObject];
    if (balls && !_ballHoldersAnimating) {
        // if ball hit destroyer while holders are being animated, then
        // this will help BVLevel to inform BVRackGenerator to call it's
        // ball destroyer method after animating holders
        _ballHoldersAnimating = YES;
        
        CGSize ballSize = [BVBall clearBall].size;
        float totalBallsWidth = (ballSize.width + _ballPadding) * balls.count;
        
        self.size = CGSizeMake(self.size.width + totalBallsWidth, self.size.height);
        _rackBar.size = CGSizeMake(self.size.width * 1.5, _rackBar.size.height);
        
        NSMutableArray *leftGroup = [NSMutableArray array];
        NSMutableArray *rightGroup = [NSMutableArray array];
        
        int totalBalls = (int)[_ballsList count];
        int ballNum = 1;
        // go through balls list and
        for (BVBall *ball in _ballsList) {
            SKSpriteNode *ballHolder = [_ballHolders objectAtIndex:ball.indexInBallsList];
            
            CGPoint ballHolderPosInRack = [self ballHolderPosInRack:ball];
            CGPoint ballPos = CGPointMake(ballHolderPosInRack.x + (self.position.x), ballHolderPosInRack.y);
            
            int moveByX = 0;
            if (ballPos.x < 0) {
                moveByX = -(totalBallsWidth / 2);
                [leftGroup addObject:ball];
            } else {
                moveByX = (totalBallsWidth / 2);
                [rightGroup addObject:ball];
            }
            
            // Don't try to move the ball if it has been released from it's holder.
            // That will make it look like flying away by wind force.
            if (!ball.inAir) {
                [ball runAction:[SKAction moveByX:moveByX y:0 duration:0.5]];
            }
            
            if (ballNum != totalBalls) {
                [ballHolder runAction:[SKAction moveByX:moveByX y:0 duration:0.5]];
            } else {
                // this is the last holder which will animate, so we add new ball's to rack right after it completes it's animation
                [ballHolder runAction:[SKAction moveByX:moveByX y:0 duration:1.0] completion:^{
                    BVBall *targetBall;
                    BVPosSide newBallPosSide = BVPosSideRight;
                    
                    if (rightGroup.count) {
                        targetBall = (BVBall *)rightGroup[0];
                        newBallPosSide = BVPosSideLeft;
                    }
                    else {
                        targetBall = (BVBall *)[leftGroup lastObject];
                    }
                    
                    int newBallIndex = targetBall.indexInBallsList;
                    CGPoint targetPos = [self ballHolderPositionOfBall:targetBall];
                    CGRect targetFrame = CGRectMake(targetPos.x - (targetBall.size.width / 2), targetPos.y, targetBall.size.width, targetBall.size.height);
                    
                    // this means we have picked targetBall from leftGroup
                    if (newBallPosSide == BVPosSideRight) {
                        // left group will only be chosen when we release last ball in the rack.
                        // So incrementing newBallIndex will make us push new balls to the end of the rack.
                        newBallIndex += 1;
                    }
                    
                    BVBall *prevNewBall;
                    for (BVBall *newBall in balls) {
                        
                        newBall.rack = self;
                        
                        // first time use target ball to set it's position
                        if (!prevNewBall) {
                            [newBall setPosRelativeTo:targetFrame side:newBallPosSide margin:_ballPadding setOtherValue:targetFrame.origin.y scalableMargin:NO];
                        } else {
                            [newBall setPosRelativeTo:prevNewBall.frame side:newBallPosSide margin:_ballPadding setOtherValue:targetFrame.origin.y scalableMargin:NO];
                            //[newBall setPosRelativeTo:prevNewBall.frame side:newBallPosSide margin:_ballPadding setOtherValue:targetFrame.origin.y scalableMargin:NO];
                        }
                        
                        // setup ball's zPosition
                        newBall.zPosition = 3.0;
                        
                        // add holder to it
                        SKSpriteNode *ballHolder = [self createBallHolderFor:newBall];
                        ballHolder.alpha = 0.0;
                        
                        float newBallY = newBall.position.y;
                        newBall.position = CGPointMake(newBall.position.x, [BVSize screenSize].height);
                        
                        // put them on rack
                        [_ballsFrame addChild:ballHolder];
                        [_ballsFrame addChild:newBall];
                        
                        [_ballHolders insertObject:ballHolder atIndex:newBallIndex];
                        [_ballsList insertObject:newBall atIndex:newBallIndex];

                        prevNewBall = newBall;
                        
                        if (newBallPosSide == BVPosSideRight) {
                            newBallIndex++;
                        }
                        
                        // then animate them onto rack
                        [ballHolder runAction:[SKAction fadeInWithDuration:0.5]];
                        [newBall runAction:[SKAction moveToY:newBallY duration:0.5]];
                    }
                    
                    [self refreshBallUserDataIndexes];
                    
                    // finished completing ball holder's animation
                    _ballHoldersAnimating = NO;
                    
                    // remove any pending balls
                    if (_ballsThatHitBallDestroyerWhileAnimatingHolders.count) {
                        NSLog(@"Late Replacing Of Balls From List.");
                        for (BVBall *ballToRemove in _ballsThatHitBallDestroyerWhileAnimatingHolders) {
                            [self removeThisBallFromRack:ballToRemove];
                        }
                        // let's remove ball's reference
                        [_ballsThatHitBallDestroyerWhileAnimatingHolders removeAllObjects];
                    }
                    
                    // now that we're done adding balls from first object, it's time to remove it from the queue
                    [_ballAdderQueue removeObjectAtIndex:0];
                    
                    // re-run this method if there are more balls in queue
                    if (_ballAdderQueue.count) {
                        [self pushBallsQueueOnRack];
                    } else {
                        _ballsHolderGoingToAnimate = NO;
                        // now post notification, so that BVLevel can finally run ballHitDestroyer method.
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewBallsAddedSuccessfully" object:self];

                        // FOR LOGGING PURPOSE ONLY
//                        NSLog(@"FINAL BALLS LIST:");
//                        for (BVBall *ball in _ballsList) {
//                            NSLog(@"ball:%@ x=%f, y=%f --- inAir:%@", ball.name, ball.position.x, ball.position.y, (ball.inAir) ? @"YES" : @"NO");
//                        }
                    }
                }];
            }
            
            ballNum++;
        }
    }
}

- (void)removeThisBallFromRack:(BVBall *)ball
{
    if (_ballHoldersAnimating) {
        NSLog(@"Ball Hit Destroyer While Animating Holders");
        [_ballsThatHitBallDestroyerWhileAnimatingHolders addObject:ball];
        // we should hide and stop ball's physics, just to make it look like we have destroyed it.
        // We'll take care of it after finishing the holder animation
        ball.hidden = YES;
        ball.physicsBody.dynamic = NO;
    } else {
        CGPoint ballHolderPos = [self ballHolderPositionOfBall:ball];
        
        // replace the hitted ball with clearBall in _ballsList (just to maintain the index count)
        BVBall *dummyBall = [BVBall dummyBall];
        dummyBall.zPosition = 3;
        dummyBall.userInteractionEnabled = NO;
        dummyBall.position = CGPointMake(ballHolderPos.x, ballHolderPos.y);
        dummyBall.indexInBallsList = ball.indexInBallsList;
        
#warning ONLY FOR TESTING PURPOSES
        // TEST: let's display  it on rack too
        //    SKSpriteNode *box = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(10, 10)];
        //    box.name = @"I'AM BOX";
        //    box.position = ballHolderPos;
        //    box.zPosition = 3.0;
        //[_ballsFrame addChild:dummyBall];
//        NSLog(@"REMOVED BALL'S HOLDER POSITION: x=%f, y=%f", ballHolderPos.x, ballHolderPos.y);
        
        // now finally replace it
        [_ballsList replaceObjectAtIndex:ball.indexInBallsList withObject:dummyBall];
        
        // remove ball from parent
        [ball removeFromParent];
    }
}

/**
 Helps get position of the ball when it was holded by it's holder.
 */
- (CGPoint)ballHolderPositionOfBall:(BVBall *)ball
{
    SKSpriteNode *holder = (SKSpriteNode *)_ballHolders[ball.indexInBallsList];
    float holderY = CGRectGetMinY(holder.frame) + (ball.size.height / 4);
    
    return CGPointMake(holder.position.x, holderY);
}

- (CGPoint)ballPosInRack:(BVBall *)ball
{
    return [_ballsFrame convertPoint:ball.position toNode:self];
}

- (CGPoint)ballHolderPosInRack:(BVBall *)ball
{
    return [_ballsFrame convertPoint:[self ballHolderPositionOfBall:ball] toNode:self];
}

- (void)stopUserInteractionOnAllBalls
{
    for (BVBall *ball in _ballsList) {
        ball.userInteractionEnabled = NO;
    }
}

/**
 Use this method after adding new balls to _ballsList.
 */
- (void)refreshBallUserDataIndexes
{
    int i = 0;
    for (BVBall *ball in _ballsList) {
        ball.indexInBallsList = i;
        i++;
    }
}

- (SKSpriteNode *)createBallHolderFor:(BVBall *)ball
{
    SKSpriteNode *ballHolder = [SKSpriteNode spriteNodeWithImageNamed:@"ball-holder"];
    ballHolder.size = [BVSize resizeUniversally:CGSizeMake(14, 80) firstTime:YES];
    ballHolder.position = CGPointMake(ball.position.x, (ball.position.y - (ball.size.height / 4)) + (ballHolder.size.height / 2));
    ballHolder.zPosition = 2.0;
    return ballHolder;
}

- (BOOL)zeroBallsInRack
{
    for (BVBall *ball in _ballsList) {
        if (ball.type == BVBallTypeBomb) {
            return NO;
        }
        
        // if ball's color is not clearColor, then we have ball in the rack.
        if (![BVColor doTheseTwoColorsMatch:@[ball.color, [UIColor clearColor]]]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Handle Touches For Rack Scrolling

- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _initialTouch = [touch locationInNode:self];
}

- (void)touchesMoved:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    // lets make the balls rack scrollable
    UITouch *touch = [touches anyObject];
    
    CGPoint movingPoint = [touch locationInNode:self];
    
    _touchMoveX = movingPoint.x - _initialTouch.x;
    
    SKAction *movePos = [SKAction moveToX:self.position.x + _touchMoveX duration:0.1];
    
    [self slowDownScrollingAction:movePos andStopAfter:80];
    
    if (!_isScrollingPaused) {
        [self runAction:movePos];
        //self.position = CGPointMake(self.position.x + _touchMoveX, self.position.y);
    }
}

- (void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
    _touchMoveX *= 2;
    // run the smooth animation
    SKAction *endingSmoothness = [SKAction moveTo:CGPointMake(self.position.x + _touchMoveX, self.position.y) duration:0.2];
    endingSmoothness.timingMode = SKActionTimingEaseOut;
    
    // only run the ending animation as far as rack haven't hit it's endpoints
    if (![self anyEndGotHit]) {
        [self runAction:endingSmoothness completion:^{
            [self snapItBack];
        }];
    }
    
    [self snapItBack];
    
    // reset _touchMoveX
    _touchMoveX = 0;
}

#pragma mark - Reset Rack --- (NOT USING)

- (void)resetBallsRack:(NSArray *)balls
{
    // remove rack reference from all balls
    for (BVBall *ball in _ballsList) {
        ball.rack = nil;
        [BVUtility cleanUpChildrenAndRemove:ball];
    }
    
    // reset some values
    [BVUtility cleanUpChildrenAndRemove:_ballsFrame];
    _ballsFrame = nil;
    [_ballHolders removeAllObjects];
    _ballHolders = nil;
    [_ballsList removeAllObjects];
    _ballsList = nil;
    
    // reset position
    self.position = CGPointMake(0, self.position.y);
    
    // Enable scrolling by default
    _isScrollingPaused = NO;
    
    _ballsList = [NSMutableArray arrayWithArray:balls];
    _ballAdderQueue = [NSMutableArray array];
    _ballsThatHitBallDestroyerWhileAnimatingHolders = [NSMutableArray array];
    
    // re-fill
    [self presentBallsOnRack];
}

- (void)resetBucketsRack:(NSArray *)buckets
{
    // reset some values
    [BVUtility cleanUpChildrenAndRemove:_bucketsFrame];
    _bucketsFrame = nil;
    [_bucketsList removeAllObjects];
    _bucketsList = nil;
    
    // reset position
    self.position = CGPointMake(0, self.position.y);
    
    // Enable scrolling by default
    _isScrollingPaused = NO;
    
    _bucketsList = [NSMutableArray arrayWithArray:buckets];
    [self addBucketsToRack];
}

#pragma mark - Utility Methods

// Make the given end of rack touch that same end of view.
- (void)moveRackToViewsEndSide:(NSString *)side withAnimation:(BOOL)animation
{
    int padding = 0;
    CGPoint newPosition = self.position;
    
    if ([side isEqualToString:@"left"]) {
        newPosition = CGPointMake(self.leftViewEndInScene + (self.size.width / 2) + padding, self.position.y);
    }
    else if ([side isEqualToString:@"right"]) {
        newPosition = CGPointMake(self.rightViewEndInScene - (self.size.width / 2) - padding, self.position.y);
    }
    
    if (animation) {
        [self runAction:[SKAction moveTo:newPosition duration:0.1]];
    }
    else {
        self.position = newPosition;
    }
    
    // re-enable the scrolling if it's paused
    _isScrollingPaused = NO;
}

- (void)snapItBack
{
    if ([self leftEndGotHit]) {
        [self removeAllActions];
        [self moveRackToViewsEndSide:@"left" withAnimation:YES];
    }
    else if ([self rightEndGotHit]) {
        [self removeAllActions];
        [self moveRackToViewsEndSide:@"right" withAnimation:YES];
    }
}

- (void)slowDownScrollingAction:(SKAction *)action andStopAfter:(float)stopPoint
{
    float newSpeed = 1;
    float leftStopPoint = stopPoint;
    float rightStopPoint = CGRectGetWidth(self.scene.view.frame) - stopPoint;
    
    if ([self leftEndGotHit] && self.leftEndInView < leftStopPoint) {
        newSpeed -= self.leftEndInView / leftStopPoint;
        action.speed = newSpeed;
    }
    else if ([self rightEndGotHit] && self.rightEndInView > rightStopPoint) {
        newSpeed = (self.rightEndInView - rightStopPoint) / stopPoint;
        action.speed = newSpeed;
    }
    
    // pause any further scrolling when action's speed becomes 0.0 (we're re-enabling the scrolling in moveRackToViewsEndSide:)
    if (self.leftEndInView > leftStopPoint || self.rightEndInView < rightStopPoint) {
        [self removeAllActions];
        _isScrollingPaused = YES;
    }
}

// This method check's if left or right end of the rack touches left or right end of view.
- (BOOL)anyEndGotHit
{
    if ([self leftEndGotHit] || [self rightEndGotHit]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)leftEndGotHit
{
    if (self.leftEndInView >= 0.0) {
        return YES;
    }
    return NO;
}

- (BOOL)rightEndGotHit
{
    if (self.rightEndInView <= CGRectGetWidth(self.scene.view.frame)) {
        return YES;
    }
    return NO;
}

#pragma mark - Property getter & setter's
- (float)leftEndInView
{
    // left end of rack in scene's x coordinates
    float leftEnd = -(self.size.width / 2);
    _leftEndInView = [self.scene convertPointToView:self.position].x + leftEnd;
    return _leftEndInView;
}

- (float)rightEndInView
{
    // right end of rack in scene's x coordinates
    float rightEnd = self.size.width / 2;
    _rightEndInView = [self.scene convertPointToView:self.position].x + rightEnd;
    return _rightEndInView;
}

- (float)leftViewEndInScene
{
    _leftViewEndInScene = CGPointMake([self.scene convertPointFromView:CGPointZero].x, 0).x;
    return _leftViewEndInScene;
}

- (float)rightViewEndInScene
{
    _rightViewEndInScene = CGPointMake([self.scene convertPointFromView:CGPointMake(CGRectGetWidth(self.scene.view.frame), 0)].x, 0).x;
    return _rightViewEndInScene;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
