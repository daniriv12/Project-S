//
//  ConcertsView.h
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "JSONDownloader.h"

@class Place;

@interface PlaceConcertsView : UIViewController <MKMapViewDelegate, MBProgressHUDDelegate, JSONDownloaderDelegate>
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSMutableArray *places;
@property (strong, nonatomic) Place *place;
@property (nonatomic, assign) int currentPlace;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) MKMapView* mapView;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (nonatomic, assign) BOOL isFromSearch;
@property (strong, nonatomic) UIBarButtonItem *nextBButton;
@property (strong, nonatomic) UIBarButtonItem *prevBButton;
@property (strong, nonatomic) UILabel *noConcerts;

- (void)setMapPosition;
- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
- (void)createArrayForNextShowtimes;

@end
