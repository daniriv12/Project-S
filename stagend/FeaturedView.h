//
//  FeaturedView.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"
#import "IASKAppSettingsViewController.h"

@interface FeaturedView : UIViewController<JSONDownloaderDelegate, MBProgressHUDDelegate, IASKSettingsDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSArray *concerts;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (strong, nonatomic) IASKAppSettingsViewController *appSettingsViewController;
@property (strong, nonatomic) UILabel *noConcerts;
@property (strong, nonatomic) NSDate *lastFeaturedUpdate;

- (void)download;
- (IASKAppSettingsViewController*)appSettingsViewController;
- (void)openSettings;

@end
