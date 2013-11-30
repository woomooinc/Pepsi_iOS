//
//  WMAppDelegate.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMAppDelegate.h"
#import "WMBlueToothController.h"
#import "WMClientDialogViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface WMAppDelegate()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WMAppDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside)
    {
        notification.alertBody = @"There are an event hosted nearby, check it out!";
    }
    else if(state == CLRegionStateOutside)
    {
        //        notification.alertBody = @"You're outside the region";
        return;
    }
    else
    {
        return;
    }
    
    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
    // If its not, iOS will display the notification to the user.
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WMBlueToothController sharedController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    self.window.rootViewController = vc;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // @howard recieve notification
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    WMClientDialogViewController * vc = (WMClientDialogViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WMClientDialogViewController"];
    self.window.rootViewController = vc;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
    // Notify user to change the identifier
    
//    [[GPUtility shareObj] setIsNotified:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    WMClientDialogViewController * vc = (WMClientDialogViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WMClientDialogViewController"];
    self.window.rootViewController = vc;
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
}

@end
