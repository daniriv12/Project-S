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

@class Artist;

@interface ArtistConcertsView : UIViewController <JSONDownloaderDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) Artist *artist;
@property (strong, nonatomic) NSArray *artists;
@property (strong, nonatomic) NSArray *sections;
@property (nonatomic, assign) BOOL isFromSearch;
@property (nonatomic, assign) int currentArtist;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (strong, nonatomic) UIBarButtonItem *nextBButton;
@property (strong, nonatomic) UIBarButtonItem *prevBButton;
@property (strong, nonatomic) UILabel *noConcerts;
@property (strong, nonatomic) UIImageView *addedToFavourites;

//Daniel Rivera
@property (nonatomic, assign) BOOL isFromConcert;




- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
- (void)createArrayForNextShowtimes;




- (void)addToFavourites;

-(IBAction)openBookingURL:(id)sender;

@end
