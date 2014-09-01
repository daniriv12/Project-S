//
//  ConcertDetailsView.h
//  stagend
//
//  Created by Giovanni Iembo on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Concert.h"
#import "JSONDownloader.h"
#import "MBProgressHUD.h"





@interface ConcertDetailsView : UIViewController<JSONDownloaderDelegate, MBProgressHUDDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) Concert *concert;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) MBProgressHUD *Hud; 
@property (strong, nonatomic) UIImageView *addedToFavourites;

//Daniel Rivera
@property ( nonatomic) BOOL VenueIsAButton;

- (void)hideEmptySeparators;
- (void)addConcert;
- (void)showClubDetails;

//Daniel Rivera

-(IBAction)shareButton;

@end
