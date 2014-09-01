//
//  Database.h
//  stagend
//
//  Created by  on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface JCLLocalNotification : NSObject 

- (id)init;
- (void)addNotificationWithID:(NSNumber *)idNumber andWithAlertMessagge:(NSString *)alertMessagge andWithTime:(NSDate *)dateTime;
- (void)removeNotificationWithID:(NSNumber *)idNumber;
- (void)reloadAllBadge;

@end