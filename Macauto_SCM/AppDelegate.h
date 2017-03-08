//
//  AppDelegate.h
//  Macauto_SCM
//
//  Created by SUNUP on 2017/3/2.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate> {
    Boolean is_actived;
    
}



@property (strong, nonatomic) UIWindow *window;


@end

