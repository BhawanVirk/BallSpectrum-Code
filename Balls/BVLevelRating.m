//
//  BVLevelRating.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/13/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVLevelRating.h"
#import "BVSize.h"
#import "BVLabelNode.h"
#import "BVColor.h"
#import "BVUtility.h"

#define percent(percentage, number) ((percentage * number) / 100)

const int TARGET_BUCKET       = 5000; // test: 1234567891;
const int NEW_BUCKET          = 1000;
const int BUCKET_CAP_EXPLODED = 1500;

@implementation BVLevelRating
{
    CGSize _viewSize;
    NSArray *_starPoints;
    NSMutableArray *_dividers;
    SKSpriteNode *_innerRect;
    SKSpriteNode *_progressBar;
}

@synthesize pointsEarned = _pointsEarned;

- (instancetype)initWithStarPoints:(NSArray *)starPoints size:(CGSize)size viewSize:(CGSize)viewSize
{
    self = [super init];
    
    if (self) {
        
        _viewSize = viewSize;
        self.size = size;
        self.numOfStarsEarned = 0;
        
        _starPoints = starPoints;
        _dividers = [NSMutableArray arrayWithCapacity:3];
        
        // [BVColor r:47 g:31 b:0];
        _innerRect = [SKSpriteNode spriteNodeWithColor:[BVColor r:0 g:0 b:0 alpha:0.3] size:self.size];
        
        UIColor *progressBarColor = [UIColor colorWithRed:233/255.0f green:182/255.0f blue:21/255.0f alpha:1.0];
        UIColor *progressBarColorDark = [UIColor colorWithRed:233/255.0f green:148/255.0f blue:21/255.0f alpha:1.0];
        // progress bar
        _progressBar = [SKSpriteNode spriteNodeWithColor:progressBarColor size:CGSizeMake(percent(0, self.size.width), self.size.height)];
        _progressBar.anchorPoint = CGPointMake(0, 0.5);
        _progressBar.position = CGPointMake(CGRectGetMinX(self.frame), 0);
        _progressBar.zPosition = 1;
        
        // add glow animation to progress bar
        SKAction *glow = [SKAction sequence:@[[SKAction colorizeWithColor:progressBarColorDark colorBlendFactor:0.0 duration:1.0],
                                              [SKAction colorizeWithColor:progressBarColor colorBlendFactor:0.0 duration:1.0],
                                              [SKAction waitForDuration:0.2]]];
        // make it run forever
        glow = [SKAction repeatActionForever:glow];
        [_progressBar runAction:glow];
        
        // add slight gradient effect on progress bar
        SKSpriteNode *progressBarGradientGlass = [SKSpriteNode spriteNodeWithImageNamed:@"rating-gradient-glass"];
        progressBarGradientGlass.size = _progressBar.size;
        progressBarGradientGlass.anchorPoint = CGPointMake(0, 0.5);
        [_progressBar addChild:progressBarGradientGlass];
        
        [_innerRect addChild:_progressBar];
        
        SKSpriteNode *innerRectBack = [SKSpriteNode spriteNodeWithImageNamed:@"rating-inner-rect"];
        innerRectBack.size = self.size;
        innerRectBack.zPosition = 3;
        [_innerRect addChild:innerRectBack];
        
        // place dividers on it
        [self placeDividersBasedOnPoints:starPoints];
        
        // add rating frame
        SKSpriteNode *frame = [SKSpriteNode spriteNodeWithImageNamed:@"rating-frame"];
        frame.zPosition = 4;
        frame.size = [BVSize resizeUniversally:CGSizeMake(115, 32) firstTime:YES];// CGSize(110, 28) is a size of innerRect Back on iPhone5. (after apply global resizing filter)
        
        [_innerRect addChild:frame];
        
        [self addChild:_innerRect];
    }
    
    return self;
}

- (void)addPointsType:(BVLevelRatingPointsType)pointsType withLabelAnimationAt:(CGPoint)labelPos
{
    // get points value from pointsType
    int points = [BVLevelRating pointsForType:pointsType];
    
    [self addPoints:points withLabelAnimationAt:labelPos];
}

- (void)addPoints:(int)points withLabelAnimationAt:(CGPoint)labelPos
{
    NSString *formattedPoints;
    UIColor *pointsLabelColor;
    
    if (points < 0) {
        formattedPoints = [NSString stringWithFormat:@"%i", points];
        pointsLabelColor = [BVColor red];
    } else {
        formattedPoints = [NSString stringWithFormat:@"+%i", points];
        pointsLabelColor = [BVColor green];
    }
    
    // add points label
    BVLabelNode *pointsLabel = [BVLabelNode notificationLabelWithText:formattedPoints color:pointsLabelColor size:BVdynamicFontSize(_viewSize) pos:labelPos];
    [self.scene addChild:pointsLabel];
    
    [self addPoints:points];
}

- (void)addPoints:(int)points
{
    // this will prevent the progress bar to grow in wrong direction
    if ((self.pointsEarned + points) < 0) {
        self.pointsEarned = 0;
    } else {
        self.pointsEarned += points;
    }
}

- (void)progressTo:(int)percentage
{
    SKAction *animateWidth = [SKAction resizeToWidth:percent(percentage, self.size.width) duration:0.3];
    [_progressBar runAction:animateWidth];
}

#pragma mark - Getter & Setter Methods

- (void)setPointsEarned:(int)pointsEarned
{
    _pointsEarned = pointsEarned;
    
    int i = 0;
    for (NSNumber *starPoint in _starPoints) {
        int starPoints = [starPoint intValue];
        SKSpriteNode *divider = [_dividers objectAtIndex:i];
        
        if (_pointsEarned >= starPoints) {
            if (![[divider.userData objectForKey:@"starPresented"] boolValue]) {
                // now present star for this divider
                [self presentStarForDivider:divider];
            }
        }
        else if (_pointsEarned < starPoints) {
            if ([[divider.userData objectForKey:@"starPresented"] boolValue]) {
                // now remove that presented star because points are
                // now less than of what required to get that star.
                [self removeStarForDivider:divider];
            }
        }
        i++;
    }
    
    // update progress bar width based on current points
    float thirdStarPoints = [[_starPoints lastObject] floatValue];
    float currentPercent = (_pointsEarned / thirdStarPoints) * 100;
    
    [self progressTo:currentPercent];
}

#pragma mark - Reset Method --- (NOT USING)

- (void)resetRatings
{
    _pointsEarned = 0;
    self.numOfStarsEarned = 0;
    _progressBar.size = CGSizeMake(0, _progressBar.size.height);
    
    for (SKSpriteNode *divider in _dividers) {
        
        // remove any presented star for this divider
        [divider enumerateChildNodesWithName:@"presented-star" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [BVUtility cleanUpChildrenAndRemove:node];
        }];
        
        // reset presented star state of this divider
        [divider.userData setObject:@NO forKey:@"starPresented"];
    }
    
}

#pragma mark - Utility Methods

+ (int)pointsForType:(BVLevelRatingPointsType)type
{
    int points;
    switch (type) {
        case BVLevelRatingPointsTypeTargetBucket:
            points = TARGET_BUCKET;
            break;
            
        case BVLevelRatingPointsTypeNewBucket:
            points = NEW_BUCKET;
            break;
            
        case BVLevelRatingPointsTypeCapExploded:
            points = BUCKET_CAP_EXPLODED;
            break;
            
        case BVLevelRatingPointsTypeNone:
            points = 0;
            break;
    }
    
    return points;
}

- (void)placeDividersBasedOnPoints:(NSArray *)points
{
    float star1 = [[points objectAtIndex:0] floatValue];
    float star2 = [[points objectAtIndex:1] floatValue];
    float star3 = [[points objectAtIndex:2] floatValue];
    
    float divider1PercentMark = (star1 / star3) * 100;
    float divider2PercentMark = (star2 / star3) * 100;
    
    float innerRectW = _innerRect.size.width;
    float innerRectHW = innerRectW / 2;
    
    float divider1X = percent(divider1PercentMark, innerRectW) - innerRectHW;
    float divider2X = percent(divider2PercentMark, innerRectW) - innerRectHW;
    
    [self createDivider:1 position:CGPointMake(divider1X, 0) visible:YES];
    [self createDivider:2 position:CGPointMake(divider2X, 0) visible:YES];
    [self createDivider:3 position:CGPointMake((innerRectW - innerRectHW) - 2, 0) visible:NO];
}

- (void)createDivider:(int)dividerId position:(CGPoint)position visible:(BOOL)isVisible
{
    SKSpriteNode *divider;
    
    if (isVisible) {
        divider = [SKSpriteNode spriteNodeWithImageNamed:@"rating-divider"];
    }
    else {
        divider = [SKSpriteNode node];
    }
    
    divider.position = position;
    divider.size = CGSizeMake(divider.size.width, _innerRect.size.height);
    divider.zPosition = 4;
    divider.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"id": @(dividerId), @"starPresented": @NO}];
    // add empty star at the bottom of divider
    [divider addChild:[self createEmptyStar]];
    
    [_innerRect addChild:divider];
    
    // store divider in _dividers based on priority
    [_dividers insertObject:divider atIndex:(dividerId - 1)];
}

- (SKSpriteNode *)createEmptyStar
{
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"rating-star-blank"];
    star.size = [BVSize resizeUniversally:CGSizeMake(20.5, 19) firstTime:YES];
    star.anchorPoint = CGPointMake(0.5, 1);
    star.zPosition = 5;
    
    return star;
}

- (void)presentStarForDivider:(SKSpriteNode *)divider
{
    // Increment the stars unlock count.
    self.numOfStarsEarned++;
    
    SKSpriteNode *presentStar = [SKSpriteNode spriteNodeWithImageNamed:@"rating-star"];
    presentStar.name = @"presented-star";
    presentStar.size = [BVSize resizeUniversally:CGSizeMake(21.5, 20) firstTime:YES];
    presentStar.anchorPoint = CGPointMake(0.5, 1);
    presentStar.zPosition = 6;
    presentStar.alpha = 0.0;
    
    [divider addChild:presentStar];
    
    // now play the animation
    CGSize resizeStarTo = [BVSize resizeUniversally:CGSizeMake(20.5, 19) firstTime:YES];
    SKAction *popIn = [SKAction sequence:@[[SKAction fadeInWithDuration:0.2], [SKAction resizeToWidth:resizeStarTo.width height:resizeStarTo.height duration:0.1]]];
    [presentStar runAction:popIn];
    
    // save a note that we've presented star for this divider
    [divider.userData setObject:@YES forKey:@"starPresented"];
}

- (void)removeStarForDivider:(SKSpriteNode *)divider
{
    // Decremet the stars unlock count.
    self.numOfStarsEarned--;
    
    // find the presented star for given divider
    [divider enumerateChildNodesWithName:@"presented-star" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        CGSize resizeTo = [BVSize resizeUniversally:CGSizeMake(21.5, 20) firstTime:YES];
        [node runAction:[SKAction sequence:@[[SKAction resizeToWidth:resizeTo.width height:resizeTo.height duration:0.1],
                                             [SKAction scaleTo:0 duration:0.2],
                                             [SKAction removeFromParent]]]];
    }];
    
    // save a note that we've no presented star for this divider
    [divider.userData setObject:@NO forKey:@"starPresented"];
}

@end
