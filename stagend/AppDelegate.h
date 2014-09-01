//
//  AppDelegate.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

- (void)registerDefaultsFromSettingsBundle;
- (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName;
- (void)updateBadge;

@end
