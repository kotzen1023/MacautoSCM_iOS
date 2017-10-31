//
//  AppDelegate.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/3/2.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "AppDelegate.h"
#import "Firebase.h"


@interface AppDelegate ()
@property long unread_sp_count;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [FIRApp configure];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].delegate = self;
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    /*UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];*/
    
    
    
    
    
    
    //Get the push notification when app is not open
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotif){
        [self handleRemoteNotification:application userInfo:remoteNotif];
    } else {
        NSLog(@"remoteNotif = null");
    }
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    //is_actived = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString *unread_badge = [defaults objectForKey:@"Badge"];
    _unread_sp_count = [unread_badge intValue];
    
    NSLog(@"Current badge = %ld", _unread_sp_count);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = _unread_sp_count;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"applicationWillEnterForeground");
    
    _unread_sp_count = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    NSLog(@"Current badge = %ld", _unread_sp_count);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self userInfo:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //clear badge
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //is_actived = true;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current Installation and save it to Parse.
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
    
    //[[FIRMessaging messaging] subscribeToTopic:@"/topics/test"];
    //NSLog(@"Subscribed to test topic");
}



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *title = [userInfo objectForKey:@"title"];
    NSString *body  = [userInfo objectForKey:@"body"];
    //NSInteger badge = [[userInfo objectForKey:@"badge"] integerValue];
    
    NSLog(@"current badge = %ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber);
    
    if (title != nil) {
        NSLog(@"title = %@", title);
    }
    
    if (body != nil) {
        NSLog(@"body = %@", body);
    }
    
    //if (badge != nil) {
        //NSLog(@"badge = %ld", (long)badge);
    //}
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Pring full message.
    NSLog(@"%@", userInfo);
    
    //if (!is_actived) {
    //    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    //}
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    //local notification
    /*UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!error) {
                                  NSLog(@"request authorization succeeded!");
                                  //[self showAlert];
                              }
                          }];
    
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Elon said:"
                                                          arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Hello Tom！Get up, let's play with Jerry!"
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    // 4. update application icon badge number
    content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1.f
                                                  repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content
                                                                          trigger:trigger];
    /// 3. schedule localNotification
    //UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"add NotificationRequest succeeded!");
        }
    }];
    */
    //send to viewcontroller
    
    if (title != nil && body != nil) {
    
        //NSDictionary *notifyDetail = @{@"title": title,
        //                             @"body": body};
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self userInfo:nil];
    }
    
}

-(void)handleRemoteNotification:(UIApplication*)application userInfo:(NSDictionary*)userInfo{
    
    if(userInfo){
        //TODO: Handle the userInfo here
        NSString *sFuncID = [[userInfo objectForKey:@"notification"] objectForKey:@"title"];
        NSLog(@"title = %@", sFuncID);
        //[[NSUserDefaults standardUserDefaults] setValue:sFuncID forKey:Key_ID_notification];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"userInfo = null");
    }
}


@end
