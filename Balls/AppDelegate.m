//
//  AppDelegate.m
//  Balls
//
//  Created by Bhawan Virk on 6/12/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "AppDelegate.h"
#import "NSUserDefaults+SecureAdditions.h"
#import "StoreObserver.h"
#import "BVSounds.h"
#import <Google/Analytics.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import GameKit;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSUUID *deviceIdentifier = [[UIDevice currentDevice] identifierForVendor];
    
//    NSLog(@"deviceIdentifier: %@", deviceIdentifier);
//    NSLog(@"defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    NSArray *identifierParts = [deviceIdentifier.UUIDString componentsSeparatedByString:@"-"];
    NSString *deviceIdentifierShort = [identifierParts componentsJoinedByString:@""];
    NSString *salt1 = @"xxxxxxxxxxxxxxxxxx";
    NSString *salt2 = @"xxxxxxxxxxxxxxxxxx";
    NSString *salt = [NSString stringWithFormat:@"%@%@%@", salt1, deviceIdentifierShort, salt2];
    // Override point for customization after application launch.
    [[NSUserDefaults standardUserDefaults] setSecret:salt];
    
    
    // Google Analytics Code
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    
    
    // authenticate game center player
    [self authenticateLocalPlayer];
    
    // Attach an observer to the payment queue
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[StoreObserver sharedInstance]];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    [[BVSounds sharedInstance] playMusic];
    
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                             didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Game Center

- (void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
        }
    };
}

@end
