//
//  AppDelegate.m
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/05/31.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import "AppDelegate.h"
@import UIKit;
@import Firebase;
@import FirebaseUI;
#import <TwitterKit/TWTRKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

//twitter Kit,Facebook Kit 初始化
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //firebase初始化
    [FIRApp configure];
    //Firestore初始化
    FIRFirestore *defaultFirestore = [FIRFirestore firestore];
    NSLog(@"%@", defaultFirestore);
    //TwitterKit初始化
    [[Twitter sharedInstance] startWithConsumerKey:@"WcmvzBV1Ob5Mwf1hcuTnReSEv" consumerSecret:@"kGcK1FA76z6gon950PFsOa7QFs7zWkcO8ujw65FzyfMMyMPkNl"];
    //FbKit初始化
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

//twitter,facebook 链接重定向
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[Twitter sharedInstance] application:application openURL:url options:options]){
        return true;//twitter 重定向
    }
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ]; //Facebook重定向
    // Add any custom logic here.
    return handled;
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
