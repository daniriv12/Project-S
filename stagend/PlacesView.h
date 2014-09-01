//
//  PlansView.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"

@class Place;

@interface PlacesView : UIViewController<JSONDownloaderDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIBarButtonItem *addPlanButton;
@property (strong, nonatomic) NSMutableArray *places;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (strong, nonatomic) Place *selectedPlace;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, strong) UIView *noFavouritesView;

- (void)addPlace:(id)sender;
- (void)showNoFavouritesView;
- (void)removeNoFavouritesView;

@end
