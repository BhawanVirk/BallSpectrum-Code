//
//  BVRollingThings.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/4/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVRollingThings.h"
#import "BVSize.h"
#import "SKSpriteNode+BVPos.h"
#import "UIImage+Scaling.h"

@implementation BVRollingThings
{
    SKSpriteNode *_lastGroundTexture;
    SKSpriteNode *_lastBigCloudTexture;
    SKSpriteNode *_lastSmallCloudTexture;
}

#pragma mark - Setups

- (void)addGrassyGround
{
    UIImage *bottomHudTexture = [UIImage imageNamed:@"bottom-hud-back"];
    
    CGSize groundTextureImgSize = [BVSize sizeOniPhones:CGSizeMake(75, 70) andiPads:CGSizeMake(115, 110)];
    UIImage *groundTextureImg = [[UIImage imageNamed:@"bottom-hud-back"] imageScaledToFitSize:groundTextureImgSize];
    float groundTextureWidth = [BVSize valueOniPhones:(bottomHudTexture.size.width * 7) andiPads:(bottomHudTexture.size.width * 11)];
    SKTexture *groundTexture = [SKTexture textureWithImage:[groundTextureImg tiledImageOfSize:CGSizeMake(groundTextureWidth, groundTextureImgSize.height)]];
    
    // ground texture 1
    SKSpriteNode *ground1 = [SKSpriteNode spriteNodeWithTexture:groundTexture];
    ground1.position = CGPointMake(CGRectGetMinX(_parentNode.frame) + (ground1.size.width / 2), CGRectGetMinY(_parentNode.frame) + (ground1.size.height / 2));
    ground1.zPosition = 9;
    [_parentNode addChild:ground1];
    
    // ground texture 2
    SKSpriteNode *ground2 = [SKSpriteNode spriteNodeWithTexture:groundTexture];
    ground2.zPosition = 9;
    [ground2 setPosRelativeTo:ground1.frame side:BVPosSideRight margin:0 setOtherValue:ground1.position.y];
    [_parentNode addChild:ground2];
    
    // ground texture 3
//    SKSpriteNode *ground3 = [SKSpriteNode spriteNodeWithTexture:groundTexture];
//    ground3.zPosition = 9;
//    [ground3 setPosRelativeTo:ground2.frame side:BVPosSideRight margin:0 setOtherValue:ground2.position.y];
//    [_parentNode addChild:ground3];
    
    _groundTextures = @[ground1, ground2];
    _lastGroundTexture = ground2;
}


- (void)addClouds
{
    CGSize bigCloudSize = [BVSize resizeUniversally:CGSizeMake(55, 38) firstTime:YES];
    CGSize smallCloudSize = [BVSize resizeUniversally:CGSizeMake(22, 15.2) firstTime:YES];
    
    // setup big clouds
    SKSpriteNode *bigCloud1 = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    bigCloud1.size = bigCloudSize;
    bigCloud1.position = CGPointMake(-bigCloudSize.width, bigCloudSize.height * 5);
    bigCloud1.alpha = 0.9;
    [_parentNode addChild:bigCloud1];
    
    SKSpriteNode *bigCloud2 = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    bigCloud2.size = bigCloudSize;
    bigCloud2.position = CGPointMake(bigCloudSize.width * 2.5, bigCloudSize.height * 2);
    [_parentNode addChild:bigCloud2];
    
    _lastBigCloudTexture = bigCloud2;
    _bigCloudTextures = @[bigCloud1, bigCloud2];
    
    SKSpriteNode *smallCloud1 = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    smallCloud1.size = smallCloudSize;
    smallCloud1.alpha = 0.4;
    smallCloud1.position = CGPointMake(-smallCloudSize.width * 5, smallCloudSize.height * 8);
    [_parentNode addChild:smallCloud1];
    
    SKSpriteNode *smallCloud2 = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    smallCloud2.size = smallCloudSize;
    smallCloud2.alpha = 0.6;
    smallCloud2.position = CGPointMake(smallCloudSize.width * 5, smallCloudSize.height * 2);
    [_parentNode addChild:smallCloud2];
    
    _lastSmallCloudTexture = smallCloud2;
    _smallCloudTextures = @[smallCloud1, smallCloud2];
}

- (SKSpriteNode *)grass
{
    SKSpriteNode *grass = [SKSpriteNode spriteNodeWithImageNamed:@"grass"];
    grass.size = [BVSize resizeUniversally:CGSizeMake(375, 150) firstTime:YES useFullWidth:YES];
    
    [BVSize outputSize:grass.size msg:@"grass.size"];
    
    return grass;
}

#pragma mark - Rolling Animations

- (void)rollBigClouds:(NSTimeInterval)timeElapsed
{
    float speed = [BVSize valueOniPhones:50 / 2 andiPads:50];
    float step = -(timeElapsed * speed);
    
    SKSpriteNode *lastTexture = _lastBigCloudTexture;
    [self rollTextures:_bigCloudTextures step:step useScreenEnd:YES lastTexture:&lastTexture];
    _lastBigCloudTexture = lastTexture;
}

- (void)rollSmallClouds:(NSTimeInterval)timeElapsed
{
    float speed = [BVSize valueOniPhones:20 / 2 andiPads:20];
    float step = -(timeElapsed * speed);
    
    SKSpriteNode *lastTexture = _lastSmallCloudTexture;
    [self rollTextures:_smallCloudTextures step:step useScreenEnd:YES lastTexture:&lastTexture];
    _lastSmallCloudTexture = lastTexture;
}

- (void)rollGround:(NSTimeInterval)timeElapsed
{
    float speed = [BVSize valueOniPhones:300 / 2 andiPads:300];
    float step = -(timeElapsed * speed);
    
    SKSpriteNode *lastTexture = _lastGroundTexture;
    [self rollTextures:_groundTextures step:step useScreenEnd:NO lastTexture:&lastTexture];
    _lastGroundTexture = lastTexture;
}

- (void)rollTextures:(NSArray *)textures step:(float)step useScreenEnd:(BOOL)useScreenEnd lastTexture:(SKSpriteNode **)lastTexture
{
    for (SKSpriteNode *texture in textures) {
        texture.position = CGPointMake(texture.position.x + step, texture.position.y);
        
        if ([self spriteOutOfBounds:texture]) {
            
            CGRect end = (*lastTexture).frame;
            
            if (useScreenEnd) {
                end = _parentNode.frame;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [texture setPosRelativeTo:end side:BVPosSideRight margin:0 setOtherValue:texture.position.y];
            });
            *lastTexture = texture;
        }
    }
    
    if (!useScreenEnd) {
        SKSpriteNode *firstTextureInArr = [textures firstObject];
        SKSpriteNode *lastTextureInArr = [textures lastObject];
        
        if (![*lastTexture isEqual:lastTextureInArr]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [firstTextureInArr setPosRelativeTo:lastTextureInArr.frame side:BVPosSideRight margin:0 setOtherValue:firstTextureInArr.position.y];
            });
        }
    }
}

- (BOOL)spriteOutOfBounds:(SKSpriteNode *)sprite
{
    float leftEdge = CGRectGetMinX(_parentNode.frame);
    //    float rightEdge = CGRectGetMaxX(_parentNode.frame);
    
    float spriteRightEdge = CGRectGetMaxX(sprite.frame);
    //    float spriteLeftEdge = CGRectGetMinX(sprite.frame);
    
    // spriteLeftEdge >= rightEdge ||
    if (spriteRightEdge <= leftEdge) {
        return YES;
    }
    return NO;
}

@end
