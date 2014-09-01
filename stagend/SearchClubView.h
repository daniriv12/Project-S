//
//  SearchClubView.h
//  stagend
//
//  Created by Giovanni Iembo on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"

@interface SearchClubView : UIViewController <JSONDownloaderDelegate, MBProgressHUDDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) NSArray *clubs;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (assign) BOOL isFirstLoad;

- (IBAction)searchClub:(id)sender;

@end
