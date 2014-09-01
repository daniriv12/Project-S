//
//  SearchPlanView.h
//  stagend
//
//  Created by Giovanni Iembo on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONDownloader.h"
#import "MBProgressHUD.h"

@interface SearchPlaceView : UIViewController <JSONDownloaderDelegate, MBProgressHUDDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *table;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) MBProgressHUD *Hud;
@property (assign) BOOL isFirstLoad;

- (IBAction)searchPlace:(id)sender;

@end
