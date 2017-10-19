//
//  PlaygroundViewController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/24/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "PlaygroundViewController.h"
#import "BVPlayground.h"
#import "BVSize.h"
#import "BVColor.h"
#import <Google/Analytics.h>

@implementation PlaygroundViewController
{
    UIView *_coverView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Infinity Land"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    skView.backgroundColor = [BVColor r:137 g:226 b:255];
    skView.ignoresSiblingOrder = YES;
    
    if (!skView.scene) {
        BVPlayground *playground = [[BVPlayground alloc] init];
        [skView presentScene:playground];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
