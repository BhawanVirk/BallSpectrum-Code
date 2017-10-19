//
//  BVFlyingObjects.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/14/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVFlyingObjectsCanvas.h"
#import "BVFlyingObjectsRow.h"
#import "BVLevel.h"
#import "BVSize.h"
#import "SKSpriteNode+BVPos.h"
#import "BitMasks.h"
#import "SKSpriteNode+BVPos.h"
#import "SDiPhoneVersion.h"
#import "BVSounds.h"

#define percent(percentage, number) ((percentage * number) / 100)

@implementation BVFlyingObjectsCanvas
{
    NSMutableArray *_rows;
    int _biggestRowIndex; // row that contains big amount of objects
    BOOL _rollingEnabled;
    BOOL _readyToShuffle;
    BOOL _isIPad;
    BOOL _switchRows;
}

- (instancetype)initWithObjects:(NSArray *)objects scrollingDirections:(NSArray *)rowScrollingDirections scrollingSpeeds:(NSArray *)rowScrollingSpeeds backAndForthRows:(NSArray *)backAndForthRows rolling:(NSArray *)rolling switchRows:(BOOL)switchRows
{
    self = [super init];
    
    if (self) {
        self.size = [BVSize resizeUniversally:CGSizeMake(0, 135) firstTime:YES useFullWidth:YES];
        //self.color = [UIColor colorWithWhite:0.5 alpha:0.1];
        
        if ([self isRowLimitExceeded:objects]) {
            NSLog(@"*** Max limit of 7 objects in row is exceed! - BVFlyingObjectsCanvas.m ***");
            return nil;
        }
        
        // speed vary on different screen sizes
        // 1 works best on iphone5 (320, 568)
        [BVSize outputSize:[BVSize originalScreenSize] msg:@"iphon5"];
        
        _rows = [NSMutableArray arrayWithArray:@[]];
        _switchRows = switchRows;
        
        // we'll use this iVar to roll out rows. And it will be used in
        // constant running loop, so running to check the device inside
        // the method will not be really smart.
        _isIPad = ([SDiPhoneVersion deviceSize] == UnknowniPad);
        
        [self addRowsWithScrollingSpeed:rowScrollingSpeeds scrollingDirections:rowScrollingDirections backAndForthRowOptions:backAndForthRows];
        
        _rollingEnabled = [rolling[0] boolValue];
        
        if ([rolling[1] isEqualToString:@"outToIn"]) {
            [self fillInRows:objects visibility:NO];
        } else {
            [self fillInRows:objects visibility:YES];
        }
    }
    
    return self;
}

- (void)addRowsWithScrollingSpeed:(NSArray *)scrollingSpeeds scrollingDirections:(NSArray *)scrollingDirections backAndForthRowOptions:(NSArray *)backAndForthRowsOptions
{
    float rowMargin = [BVSize valueOniPhones:5 andiPads:5];
    BVFlyingObjectsRow *previousRow;
    
    for (int i = 0; i < scrollingSpeeds.count; i++) {
        int scrollingSpeed = [scrollingSpeeds[i] intValue];
        int scrollingDirection = [scrollingDirections[i] intValue];
        BOOL isBackAndForthRow = [backAndForthRowsOptions[i] boolValue];
        
        BVFlyingObjectsRow *row = [[BVFlyingObjectsRow alloc] initWithScrollingSpeed:scrollingSpeed andDirection:scrollingDirection];
        row.isBackAndForthRow = isBackAndForthRow;
        
        if (previousRow) {
            [row setPosRelativeTo:previousRow.frame side:BVPosSideBottom margin:rowMargin];
        }
        else {
            row.position = CGPointMake(0, CGRectGetMaxY(self.frame) - (row.size.height / 2));
        }
        
        [self addChild:row];
        [_rows addObject:row];
        
        previousRow = row;
    }
}

- (void)fillInRows:(NSArray *)rowsQueue visibility:(BOOL)visible
{
    float startingPoint;
    int rowPosInArray = 0;
    int activeObjIndex = 0;
    _activeBallGiverFlyingObjects = [NSMutableArray array];
    
    for (NSArray *rowObjects in rowsQueue) {
        
        if (!rowObjects.count) {
            rowPosInArray++;
            continue;
        }
        
        BVFlyingObjectsRow *currRow = (BVFlyingObjectsRow *)_rows[rowPosInArray];
        int rowScrollingDirection = currRow.scrollingDirection;
        
        if (visible) {
            if (rowScrollingDirection == -1) {
                startingPoint = CGRectGetMinX(self.frame);
            }
            else {
                startingPoint = CGRectGetMaxX(self.frame);
            }
        }
        else {
            if (rowScrollingDirection == -1) {
                startingPoint = CGRectGetMaxX(self.frame);
            }
            else {
                startingPoint = CGRectGetMinX(self.frame);
            }
        }
        
        for (int i = 0; i < rowObjects.count; i++) {
            
            BVFlyingObject *obj = rowObjects[i];
            
            // first object will always touch the left edge of row
            if (i == 0) {
                if (rowScrollingDirection == 1) {
                    obj.position = CGPointMake(startingPoint - (obj.size.width / 2), 0);
                }
                else {
                    obj.position = CGPointMake(startingPoint + (obj.size.width / 2), 0);
                }
            }
            else {
                BVFlyingObject *previousObjectInRow = (BVFlyingObject *)rowObjects[i-1];
                
                if (rowScrollingDirection == 1) {
                    [obj setPosRelativeTo:previousObjectInRow.frame side:BVPosSideLeft margin:0];
                }
                else {
                    [obj setPosRelativeTo:previousObjectInRow.frame side:BVPosSideRight margin:0];
                }
            }
            
            obj.originalPosition = obj.position;
            obj.rowIndex = rowPosInArray;
            obj.isBehindCurtains = [self objectOutOfBounds:obj];
            [currRow addChild:obj];
            
            if (i == (rowObjects.count - 1)) {
                currRow.lastFlyingObject = obj;
                
//                NSLog(@"last object out of bounds? %@", (obj.isBehindCurtains) ? @"YES" : @"NO");
            }
            
            // put it in active flying objects list
            [_activeBallGiverFlyingObjects addObject:obj];
            obj.indexInActiveObjectsList = activeObjIndex;
            activeObjIndex++;
        }
        
//        NSLog(@"Row no 1's last object: %@", ((BVFlyingObjectsRow *)_rows[0]).lastFlyingObject);
        
        rowPosInArray++;
    }
}

- (void)rollRows:(NSTimeInterval)timeElapsed
{
    if (!_readyToShuffle && [self isLastObjectPresentedOnScreenOfRow:_biggestRowIndex]) {
        _readyToShuffle = YES;
    }
    
    if (_rollingEnabled) {
        
        for (int i=0; i < _rows.count; i++) {
            
            BVFlyingObjectsRow *row = (BVFlyingObjectsRow *)_rows[i];
            int scrollingDirection = row.scrollingDirection;

            float scrollingSpeed = (float)row.scrollingSpeed;
            // twice the speed on iPad's
            scrollingSpeed = (_isIPad) ? scrollingSpeed * 2 : scrollingSpeed;
            float step;
            
            //NSLog(@"step: %f", step);
            
            if (row.isBackAndForthRow) {

                for (BVFlyingObject *obj in row.children) {
                    float objWidth = obj.size.width;
                    float distanceToRight = objWidth * obj.flyAreaOnRight;
                    float distanceToLeft = objWidth * obj.flyAreaOnLeft;
                    float objPosX = obj.position.x;
                    
                    step = (timeElapsed * scrollingSpeed);
                    if (obj.flySpeedChangeBy > 0) {
                        step *= obj.flySpeedChangeBy;
                    } else if (obj.flySpeedChangeBy < 0) {
                        step /= abs(obj.flySpeedChangeBy);
                    }
                    
                    // we need either left or right area to move objects
                    if (distanceToLeft || distanceToRight) {
                        if (objPosX >= (obj.originalPosition.x + distanceToRight) && (obj.flyingToSide == BVFlyingObjectFlyToSideRight)) {
                            obj.flyingToSide = BVFlyingObjectFlyToSideLeft;
                        }
                        else if (objPosX <= (obj.originalPosition.x - distanceToLeft) && (obj.flyingToSide == BVFlyingObjectFlyToSideLeft)) {
                            obj.flyingToSide = BVFlyingObjectFlyToSideRight;
                        }
                        
                        if (objPosX <= (obj.originalPosition.x + distanceToRight) && (obj.flyingToSide == BVFlyingObjectFlyToSideRight)) {
                            obj.position = CGPointMake(objPosX + step, obj.position.y);
                        }
                        else if (objPosX >= (obj.originalPosition.x - distanceToLeft) && (obj.flyingToSide == BVFlyingObjectFlyToSideLeft)) {
                            obj.position = CGPointMake(objPosX - step, obj.position.y);
                        }
                    }
                }
                
            }
            else {
                // normal row's steps use scrollingDirection too
                step = scrollingDirection * (timeElapsed * scrollingSpeed);
                for (BVFlyingObject *obj in row.children) {
                    obj.position = CGPointMake(obj.position.x + step, obj.position.y);
                    
                    // check if object got out of bounds and we don't even know it's behind curtains (aka: out of bounds).
                    if ([self objectOutOfBounds:obj] && !obj.isBehindCurtains && _readyToShuffle) {
                        
                        obj.isBehindCurtains = YES;
                        
                        // immediately switch to random row if enabled
                        if (_switchRows) {
                            [self moveObjectToRandomRow:obj];
                        }
                        else {
                            [self moveObjectToEnd:obj ofRow:row];
                        }
                    }
                    else if (![self objectOutOfBounds:obj]) {
                        obj.isBehindCurtains = NO;
                    }
                }
                
                // This here fixes issue of blank space between first and last object
                // once we have moved first object to the end.
                if ([self isRowFull:row]) {
                    BVFlyingObject *firstObject = (BVFlyingObject *)[row.children firstObject];
                    BVFlyingObject *lastObject = (BVFlyingObject *)[row.children lastObject];
                    BVPosSide side = (row.scrollingDirection == 1) ? BVPosSideLeft : BVPosSideRight;
                    
                    if (![row.lastFlyingObject isEqual:lastObject]) {
                        [firstObject setPosRelativeTo:lastObject.frame side:side margin:0];
                    }
                }
            }

        }
    }
}

#warning Issue - What if two objects spawn at same location at same time? They will be overlapsed! Fix it!
- (void)moveObjectToRandomRow:(BVFlyingObject *)object
{
    // remove it from the current row
    [object removeFromParent];
    
    // choose a random row
    int randomRowNum = (int)(arc4random() % _rows.count);
    BVFlyingObjectsRow *selectedRow = _rows[randomRowNum];
    
    // reset the position of object
    //[self repositionObject:object afterLastObject:lastObjectInSelectedRow ofRow:selectedRow];
    [self moveObjectToEnd:object ofRow:selectedRow];
    
    // update row index property of object
    object.rowIndex = randomRowNum;
    
    // add object to it
    [selectedRow addChild:object];
}

//- (void)repositionObject:(BVFlyingObject *)object afterLastObject:(BVFlyingObject *)lastObject ofRow:(BVFlyingObjectsRow *)row
- (void)moveObjectToEnd:(BVFlyingObject *)object ofRow:(BVFlyingObjectsRow *)row
{    
    BVFlyingObject *lastObject = row.lastFlyingObject;
    
    // reset the position based on selected rows scrolling direction
    if (row.scrollingDirection == -1) {
        
        float lastObjRightEdge = (lastObject) ? CGRectGetMaxX(lastObject.frame) : 0;
        float screenRightEdge = CGRectGetMaxX(self.frame);
        
        if (lastObjRightEdge > screenRightEdge) {
            [object setPosRelativeTo:lastObject.frame side:BVPosSideRight margin:0];
        }
        else {
            [object setPosRelativeTo:self.frame side:BVPosSideRight margin:0];
        }
    }
    else {
        
        float lastObjLeftEdge = (lastObject) ? CGRectGetMinX(lastObject.frame) : 0;
        float screenLeftEdge = CGRectGetMinX(self.frame);
        
        if (lastObjLeftEdge < screenLeftEdge) {
            [object setPosRelativeTo:lastObject.frame side:BVPosSideLeft margin:0];
        }
        else {
            [object setPosRelativeTo:self.frame side:BVPosSideLeft margin:0];
        }
    }
    
    row.lastFlyingObject = object;
    
    //NSLog(@"object: x=%f, y=%f", object.position.x, object.position.y);
}

/**
 Doing collision detection in a method for the sake of brevity
 */
#pragma mark - Collision Detection
- (void)objectGotHit:(BVFlyingObject *)object byBall:(BVBall *)ball
{
    float objPosY = ((BVFlyingObjectsRow *)_rows[object.rowIndex]).position.y;
    CGPoint objPos = CGPointMake(object.position.x, objPosY);
    
    // find out a reference to the object
    
    NSLog(@"Object Of Type: %lu Got Hit", (unsigned long)object.type);
    
    switch (object.type) {
            
        case BVFlyingObjectTypePointsWithCap:
            
            if ([object isCapped]) {
                [self destroyObjectCap:object withBall:ball];
            } else {
                // transform into blank object
                [object transformIntoBlankObject];
                
                [_level.hudBottom.levelRating addPoints:object.givePoints withLabelAnimationAt:ball.position];
                
                // play banner sound
                [self runAction:[BVSounds flyingObjectBanner]];
            }
            break;

        case BVFlyingObjectTypePoints:
            // transform into blank object
            [object transformIntoBlankObject];
        
            // now give or take points
            [_level.hudBottom.levelRating addPoints:object.givePoints withLabelAnimationAt:ball.position];
            
            // play banner sound
            [self runAction:[BVSounds flyingObjectBanner]];
            break;
            
        case BVFlyingObjectTypeTimerWithCap:
            
            if ([object isCapped]) {
                [self destroyObjectCap:object withBall:ball];
            } else {
                // transform into blank object
                [object transformIntoBlankObject];
                
                [_level.hudBottom addTimeToTimer:object.giveTime withLabelAt:ball.position];
                
                // play banner sound
                [self runAction:[BVSounds flyingObjectBanner]];
            }
            break;
        
        case BVFlyingObjectTypeTimer:
            // transform into blank object
            [object transformIntoBlankObject];
            
            [_level.hudBottom addTimeToTimer:object.giveTime withLabelAt:ball.position];
            
            // play banner sound
            [self runAction:[BVSounds flyingObjectBanner]];
            break;
            
        case BVFlyingObjectTypeObstacle:
            
            if (object.obstacleType == BVFlyingObjectObstacleTypeSpikes) {
                
                BOOL explodeBall = NO;
                if (object.blinkingInterval) {
                    if (object.alpha > 0.5) {
                        explodeBall = YES;
                    }
                } else {
                    explodeBall = YES;
                }
                
                if (explodeBall) {
                    [_level explodeBall:ball at:ball.position];
                }
            }
            break;
            
        case BVFlyingObjectTypeBallAdder:
            // transform into blank object
            [object transformIntoBlankObject];
            
            // WE DONT NEED TO REPLACE IT IN ACTIVE OBJECTS LIST, BECAUSE WE HAD ALREADY CONVERTED INTO BLANK OBJECT ABOVE.
            // replace it with blank object in active flying objects list
            //[_activeBallGiverFlyingObjects replaceObjectAtIndex:object.indexInActiveObjectsList withObject:[BVFlyingObject Blank]];
            
            _level.ballsRack.ballsHolderGoingToAnimate = YES;
            
            // play banner sound
            [self runAction:[BVSounds flyingObjectBanner]];
            
            [self generateAndAddBallsListToRack:object];
            break;
            
        case BVFlyingObjectTypeRowSpeedModifier:
            // transform into blank object
            [object transformIntoBlankObject];
            
            if (object.increaseRowSpeedBy) {
                [self increaseSpeedOfRow:object.rowIndex by:object.increaseRowSpeedBy];
            } else {
                [self decreaseSpeedOfRow:object.rowIndex by:object.decreaseRowSpeedBy];
            }
            
            // play banner sound
            [self runAction:[BVSounds flyingObjectBanner]];
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Collision Detection Helpers

- (void)increaseSpeedOfRow:(int)rowIndex by:(int)by
{
    BVFlyingObjectsRow *row = (BVFlyingObjectsRow *)_rows[rowIndex];
    row.scrollingSpeed *= by;
}

- (void)decreaseSpeedOfRow:(int)rowIndex by:(int)by
{
    BVFlyingObjectsRow *row = (BVFlyingObjectsRow *)_rows[rowIndex];
    row.scrollingSpeed /= by;
}

- (void)destroyObjectCap:(BVFlyingObject *)obj withBall:(BVBall *)ball
{
    if (ball.type == BVBallTypeBomb) {
        [_level explodeCapAt:ball.position withBall:ball];
        [obj destroyCap];
    } else {
        [_level explodeBall:ball at:ball.position];
    }
}

- (void)generateAndAddBallsListToRack:(BVFlyingObject *)obj
{
    __weak BVFlyingObjectsCanvas *weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background thread
        
        NSMutableArray *ballsList = [NSMutableArray array];
        
        int i = obj.quantityOfBallsToGive;
        while (i != 0) {
            
            BVBall *ball;
            
            if (obj.ballType == BVBallTypeBomb) {
                ball = [BVBall ballWithType:BVBallTypeBomb];
            }
            else if (obj.ballType == BVBallTypeColored) {
                ball = [BVBall ballColored:obj.ballColor];
            }
            
            [ballsList addObject:ball];
            i--;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // Main thread. Update UI here
            [weakSelf.level.ballsRack addBalls:ballsList];
        });
    });
}

#pragma mark - Utility Methods
- (BOOL)isRowLimitExceeded:(NSArray *)rows
{
    BOOL limitExceeded = NO;
    int rowNum = 0;
    int objectsInRow = 0;
    // each row can only fit in 7 objects at max
    for (NSArray *rowObjects in rows) {
        if (rowObjects.count > 7) {
            limitExceeded = YES;
        }
        
        if (rowObjects.count > objectsInRow) {
            objectsInRow = (int)rowObjects.count;
            _biggestRowIndex = rowNum;
        }
        
        rowNum++;
    }
    
    return limitExceeded;
}

- (BOOL)isRowFull:(BVFlyingObjectsRow *)row
{
    if (row.children.count == 7) {
        return YES;
    }
    return NO;
}

- (BOOL)isLastObjectPresentedOnScreenOfRow:(int)rowNum
{
    BVFlyingObjectsRow *row = (BVFlyingObjectsRow *)_rows[rowNum];
    BVFlyingObject *lastObj = row.lastFlyingObject;
    
    if (![self objectOutOfBounds:lastObj]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)objectOutOfBounds:(BVFlyingObject *)obj
{
    float leftEdge = CGRectGetMinX(self.frame);
    float rightEdge = CGRectGetMaxX(self.frame);
    
    float objectRightEdge = CGRectGetMaxX(obj.frame);
    float objectLeftEdge = CGRectGetMinX(obj.frame);
    
    if (objectLeftEdge >= rightEdge || objectRightEdge <= leftEdge) {
        return YES;
    }
    return NO;
}
@end
