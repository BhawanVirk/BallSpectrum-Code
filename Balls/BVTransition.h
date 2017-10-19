//
//  BVLevelsPresenter.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/17/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVTransition : NSObject

- (void)presentNewScene:(SKScene *)newScene oldScene:(SKScene *)oldScene block:(void(^)())customBlock;
- (void)presentNewScene:(SKScene *)newScene oldScene:(SKScene *)oldScene waitingText:(NSString *)waitingText block:(void(^)())customBlock;
@end
