//
//  BVFadeSegue.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/19/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVFadeSegue.h"

@implementation BVFadeSegue

- (void)perform
{
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    
    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
