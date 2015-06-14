//
//  AppDelegate.m
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import "AppDelegate.h"

#import "Geotification.h"
#import "GeotificationsViewController.h"

#import "Utilities.h"

@import CoreLocation;

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil]];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    return YES;
}

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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self handleRegionEvent:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self handleRegionEvent:region];
    }
}

#pragma mark - Helpers

- (void)handleRegionEvent:(CLRegion *)region{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        NSString *message = [self noteFromRegionIdentifier:region.identifier];
        if (message) {
            UIViewController *viewController = self.window.rootViewController;
            if (viewController) {
                [Utilities showSimpleAlertWithTitle:nil message:message viewController:viewController];
            }
        }
    }else{
        UILocalNotification *notification = [UILocalNotification new];
        [notification setAlertBody:[self noteFromRegionIdentifier:region.identifier]];
        [notification setSoundName:@"Default"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (NSString *)noteFromRegionIdentifier:(NSString *)identifier{
    NSArray *savedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedItemsKey];
    if(savedItems){
        for (id savedItem in savedItems) {
            Geotification *geotification = [NSKeyedUnarchiver unarchiveObjectWithData:savedItem];
            if ([geotification isKindOfClass:[Geotification class]]) {
                if ([geotification.identifier isEqualToString:identifier]) {
                    return geotification.note;
                }
            }
        }
    }
    return nil;
}

@end
