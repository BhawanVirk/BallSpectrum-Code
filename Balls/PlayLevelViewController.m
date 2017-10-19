//
//  PlayLevelViewController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/24/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "PlayLevelViewController.h"
#import "BVLevelLoader.h"
#import "BVSize.h"
#import "BVColor.h"
#import "BVUtility.h"
#import "BVLevelLoader.h"
#import <Google/Analytics.h>

@implementation PlayLevelViewController
{
    UIView *_coverView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"Level Page: %i", _levelNum]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.view.frame];
        _coverView.backgroundColor = [BVColor r:137 g:226 b:255];
        [self.view addSubview:_coverView];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    skView.backgroundColor = [BVColor r:137 g:226 b:255];
    skView.ignoresSiblingOrder = YES;
    
    if (skView.scene) {
        BVLevelLoader *scene = (BVLevelLoader *)skView.scene;
        
        if ([scene isKindOfClass:[BVLevelLoader class]]) {
            if (scene.levelNum && scene.levelNum != _levelNum) {
                BVLevelLoader *level = [[BVLevelLoader alloc] initWithLevel:_levelNum size:[BVSize originalScreenSize] showGoalIntroducer:YES presentingFromHomePage:self.presentingFromHomePage];
                [skView presentScene:level];
            }
        }
    }
    else {
        BVLevelLoader *level = [[BVLevelLoader alloc] initWithLevel:_levelNum size:[BVSize originalScreenSize] showGoalIntroducer:YES presentingFromHomePage:self.presentingFromHomePage];
        [skView presentScene:level];
    }
    
    if (_coverView) {
        [UIView animateWithDuration:0.5 animations:^{
            _coverView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_coverView removeFromSuperview];
        }];
    }
}

//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    
//    
//}

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
