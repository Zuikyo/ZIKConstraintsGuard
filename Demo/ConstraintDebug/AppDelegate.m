//
//  AppDelegate.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "AppDelegate.h"
#import "ZIKConstraintsGuard.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ZIKConstraintsGuard monitorUnsatisfiableConstraintWithHandler:^(UIView *view, UIViewController *viewController, NSLayoutConstraint *constraintToBreak, NSArray<NSLayoutConstraint *> *currentConstraints, NSString *description) {
        
        NSString *className = NSStringFromClass([viewController class]);
        if ([className hasPrefix:@"UI"] && ![className isEqualToString:@"UINavigationController"]) {
            NSLog(@"ignore conflict in system view:%@",viewController);
            return;
        }
        
        //write error to your log file
        NSLog(@"%@",description);
    }];
    
    [ZIKConstraintsGuard monitorErrorFromLayoutviewsWithHandler:^(UIView * _Nonnull view, UIViewController * _Nullable viewController, NSString * _Nonnull description) {
        
        //write error to your log file before crash
        NSLog(@"%@",description);
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
