//
//  BVPlaygroundHud.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/31/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface BVPlaygroundHud : SKSpriteNode

@property (nonatomic) int score;
@property (nonatomic) int coinsCollected;

- (void)resetScores;

@end
