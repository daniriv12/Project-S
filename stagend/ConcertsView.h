//
//  ConcertsView.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"

@interface ConcertsView : UIViewController<JSONDownloaderDelegate, MBProgressHUDDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) NSMutableArray *concerts;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (nonatomic, strong) UIView *noFavouritesView;

- (void)editBookmarks:(id)sender;
- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
- (void)createArrayForNextShowtimes;
- (void)showNoFavouritesView;
- (void)removeNoFavouritesView;

@end
