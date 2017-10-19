//
//  BVLevelsPresenter.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/17/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVTransition.h"
#import "BVSize.h"
#import "BVColor.h"
#import "BVUtility.h"

@implementation BVTransition

- (void)presentNewScene:(SKScene *)newScene oldScene:(SKScene *)oldScene block:(void(^)())customBlock
{
    [self presentNewScene:newScene oldScene:oldScene waitingText:@"Loading..." block:customBlock];
}

- (void)presentNewScene:(SKScene *)newScene oldScene:(SKScene *)oldScene waitingText:(NSString *)waitingText block:(void(^)())customBlock
{
    customBlock();
    
    SKScene *dummyScene = [SKScene sceneWithSize:[BVSize originalScreenSize]];
    dummyScene.anchorPoint = CGPointMake(0.5, 0.5);
    dummyScene.backgroundColor = [UIColor whiteColor];
    dummyScene.userInteractionEnabled = YES;
    [oldScene.view presentScene:dummyScene];
    
    // add loading node to dummy scene
    SKSpriteNode *loadingNode = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:dummyScene.size];
    loadingNode.zPosition = 1;
    SKLabelNode *loading = [SKLabelNode labelNodeWithText:waitingText];
    loading.fontColor = [UIColor blackColor];
    [loadingNode addChild:loading];
    [dummyScene addChild:loadingNode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [BVUtility cleanUpChildrenAndRemove:oldScene];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [dummyScene.view presentScene:newScene transition:[SKTransition crossFadeWithDuration:1.0]];
//            [BVUtility cleanUpChildrenAndRemove:dummyScene];
        });
    });
}

@end
