//
//  LevelSummary.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 7/26/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVLevelSummary : SKScene

- (instancetype)initWithSummary:(NSDictionary *)summary ofLevel:(int)level presentingFromHomePage:(BOOL)presentingFromHomePage;

@end
