//
//  ClubsView.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"

@interface ClubsView : UIViewController <JSONDownloaderDelegate, MBProgressHUDDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *clubs;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, strong) UIView *noFavouritesView;

- (void)addClub:(id)sender;
- (void)showNoFavouritesView;
- (void)removeNoFavouritesView;

@end
