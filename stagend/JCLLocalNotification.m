//
//  Database.m
//  
//
//  Created by  on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JCLLocalNotification.h"

@implementation JCLLocalNotification


- (id)init {
    
    self = [super init];
    if (self) {
    }
    return self;
    
}

- (void)addNotificationWithID:(NSNumber *)idNumber andWithAlertMessagge:(NSString *)alertMessagge andWithTime:(NSDate *)dateTime {
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    if (!localNotification) {
        return;
    }
    
    // Set the fire date/time
    [localNotification setFireDate:dateTime];
    [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
    
    // Create a payload to go along with the notification
    NSDictionary *data = [NSDictionary dictionaryWithObject:idNumber forKey:@"id"];
    [localNotification setUserInfo:data];
    
    [localNotification setAlertBody:alertMessagge];
    [localNotification setAlertAction:@"Open App"];
    [localNotification setHasAction:YES];  
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    // Schedule the notification        
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [self reloadAllBadge];
    
}

- (void)removeNotificationWithID:(NSNumber *)idNumber {

    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    
    NSLog(@"scheduledLocalNotifications = %d", [eventArray count]);
    NSLog(@"id to remove = %@", idNumber);
    
    for (UILocalNotification *event in eventArray) {
        
        NSDictionary *userInfoCurrent = event.userInfo;
        NSNumber *uid = [userInfoCurrent valueForKey:@"id"];
        NSLog(@"%@", userInfoCurrent);
        
        if ([uid isEqualToNumber:idNumber]) {
            //Cancelling local notification
            [app cancelLocalNotification:event];
            NSLog(@"Removed id = %@", uid);
            [self reloadAllBadge];
            break;
        }
        
    }
    
}

- (void)reloadAllBadge {
    
    NSArray *notifArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    int count = [notifArray count];
    for (int x = 0; x < count; x++) 
    {
        if (count > 0)
        {
            UILocalNotification *localNotif = [notifArray objectAtIndex:x];
            [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
            localNotif.applicationIconBadgeNumber = x + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        } 
    }
    
}

@end
