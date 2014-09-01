//
//  ClubDetailView.h
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"

@class Club;

@interface ClubDetailsView : UIViewController <MKMapViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *name;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *genre;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *address;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *city;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *addToFavouritesButton;
@property (unsafe_unretained, nonatomic) IBOutlet MKMapView *mapView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *openInMaps;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *addedToFavourites;

@property (strong, nonatomic) MBProgressHUD *Hud;
@property (strong, nonatomic) Club *club;

- (IBAction)addToFavourites:(id)sender;
- (void)setMapPosition;
- (IBAction)openMaps:(id)sender;

@end
