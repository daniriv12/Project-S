//
//  SearchArtistView.h
//  stagend
//
//  Created by Giovanni Iembo on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"

@interface SearchArtistView : UIViewController <UITableViewDataSource, UITableViewDelegate, JSONDownloaderDelegate, MBProgressHUDDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) NSArray *artists;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (assign) BOOL isFirstLoad;

- (IBAction)searchArtist:(id)sender;

@end
