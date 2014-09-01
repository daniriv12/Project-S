//
//  ConcertsView.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "JSONDownloader.h"

@class Club;

@interface ClubConcertsView : UIViewController <JSONDownloaderDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) Club *club;
@property (strong, nonatomic) NSArray *clubs;
@property (nonatomic, assign) int currentClub;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) UIBarButtonItem *nextBButton;
@property (strong, nonatomic) UIBarButtonItem *prevBButton;
@property (nonatomic, assign) BOOL isFromSearch;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (strong, nonatomic) UILabel *noConcerts;
@property (strong, nonatomic) UIImageView *addedToFavourites;

- (void)clubDetails;
- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
- (void)createArrayForNextShowtimes;
- (void)addToFavourites;

@end
