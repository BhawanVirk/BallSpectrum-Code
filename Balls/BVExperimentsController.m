//
//  BVExperimentsController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 1/4/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import "BVExperimentsController.h"
#import "BVLevelSummary.h"

@implementation BVExperimentsController

- (void)viewDidLoad
{
    SKView *skView = (SKView *)self.view;
    
    NSDictionary *summaryData = @{@"pointsEarnedAndTarget": @[@(25000), @(33000)],
                                  @"starsEarned": @(2)
                                  };
    
    BVLevelSummary *levelSummary = [[BVLevelSummary alloc] initWithSummary:summaryData ofLevel:8 presentingFromHomePage:NO];
    
    [skView presentScene:levelSummary];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
