//
//  GuideViewController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 12/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "GuideViewController.h"
#import "GuideContentViewController.h"
#import "BVColor.h"
#import "BVSize.h"
#import "BVButton.h"

@interface GuideViewController () <UIPageViewControllerDataSource>

@property (nonatomic) UIPageViewController *pageViewController;

@end

@implementation GuideViewController
{
    BVButton *_closeButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];//[BVColor r:137 g:226 b:255];
    // initialize pageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.pageViewController.dataSource = self;
    
    // setup it's starting view
    GuideContentViewController *startingViewController = [[GuideContentViewController alloc] initWithPageIndex:0];
    [_pageViewController setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // add close button
    float buttonMargin = [BVSize valueOniPhones:5 andiPads:10];
    CGSize buttonSize = [BVSize sizeOniPhone4s:CGSizeMake(22, 22) iPhone5To6sPlus:CGSizeMake(24, 24) iPad:CGSizeMake(28, 28)];
    _closeButton = [BVButton CloseButtonOfSize:buttonSize];
    _closeButton.frame = CGRectMake(buttonMargin, buttonMargin, buttonSize.width, buttonSize.height);
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
}

- (GuideContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([GuideContentViewController totalPages] == 0) || (index > [GuideContentViewController totalPages])) {
        return nil;
    }
    
    GuideContentViewController *contentViewController = [[GuideContentViewController alloc] initWithPageIndex:index];
    
    return contentViewController;
}

#pragma mark - Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GuideContentViewController *)viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GuideContentViewController *)viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [GuideContentViewController totalPages]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [GuideContentViewController totalPages];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Button Handler

- (void)closeButtonPressed:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GuideViewControllerDismissed" object:self];
    }];
}

#pragma mark - Default View Settings
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end