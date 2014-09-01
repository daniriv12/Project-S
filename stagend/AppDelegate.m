//
//  AppDelegate.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "PlacesView.h"
#import "ArtistsView.h"
#import "ClubsView.h"
#import "ConcertsView.h"
#import "FeaturedView.h"
#import "StagendDB.h"
#import "JCLLocalNotification.h"
#import "JCLLocationController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
 
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"language"]) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray* languages = [userDefaults objectForKey:@"AppleLanguages"];
        [languages insertObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"] atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1 = [[FeaturedView alloc] initWithNibName:@"FeaturedView" bundle:nil];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    navController1.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIViewController *viewController2 = [[PlacesView alloc] initWithNibName:@"PlacesView" bundle:nil];
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    navController2.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIViewController *viewController3 = [[ArtistsView alloc] initWithNibName:@"ArtistsView" bundle:nil];
    UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    navController3.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIViewController *viewController4 = [[ClubsView alloc] initWithNibName:@"ClubsView" bundle:nil];
    UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    navController4.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIViewController *viewController5 = [[ConcertsView alloc] initWithNibName:@"ConcertsView" bundle:nil];
    UINavigationController *navController5 = [[UINavigationController alloc] initWithRootViewController:viewController5];
    navController5.navigationBar.barStyle = UIBarStyleBlack;
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, navController4, navController5, nil];
    self.window.rootViewController = self.tabBarController;
    
    //Daniel Rivera
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.tabBar.opaque = YES;
    
    [self.window makeKeyAndVisible];
    [self registerDefaultsFromSettingsBundle];
    [self updateBadge];
    [[JCLLocationController sharedInstance] startUpdates];
    
    
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultsFromPlistNamed:@"Root"]];
    
}

- (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName {
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    NSString *plistFullName = [NSString stringWithFormat:@"%@.plist", plistName];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plistFullName]];
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id value = [prefSpecification objectForKey:@"DefaultValue"];
        if(key && value) {
            [defaults setObject:value forKey:key];
        } 
        
        NSString *type = [prefSpecification objectForKey:@"Type"];
        if ([type isEqualToString:@"PSChildPaneSpecifier"]) {
            NSString *file = [prefSpecification objectForKey:@"File"];
            [defaults addEntriesFromDictionary:[self defaultsFromPlistNamed:file]];
        }        
    }
        
    [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex: 0];
    
    if (![language isEqualToString:@"it"] && ![language isEqualToString:@"es"] && ![language isEqualToString:@"de"] && ![language isEqualToString:@"fr"]) {
        language = @"en";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return defaults;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [self updateBadge];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
    
    NSLog(@"Incoming notification in running app");
    application.applicationIconBadgeNumber = 0;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Concert Notification", @"")
                                                    message:notification.alertBody
                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
}

- (void)updateBadge {
    int concerts = [[[StagendDB sharedInstance] getConcerts] count];
    
    if (concerts > 0) {
        [(UIViewController *)[self.tabBarController.viewControllers objectAtIndex:4] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", concerts];
    }
    else {
        [(UIViewController *)[self.tabBarController.viewControllers objectAtIndex:4] tabBarItem].badgeValue = nil;
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    JCLLocalNotification *notification = [[JCLLocalNotification alloc] init];
    [notification reloadAllBadge];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
