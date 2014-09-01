//
//  SearchPlanView.m
//  stagend
//
//  Created by Giovanni Iembo on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchPlaceView.h"
#import "JSONParser.h"
#import "Place.h"
#import "PlaceDB.h"
#import "StagendDB.h"
#import "PlaceCell.h"
#import "PlaceCellView.h"
#import "PlaceConcertsView.h"

@implementation SearchPlaceView
@synthesize table, textField, searchButton, places, Hud, isFirstLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search city", @"");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)hideEmptySeparators {
	
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.table setTableFooterView:v];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.table.rowHeight = 80.0;
    self.table.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.textField becomeFirstResponder];
    self.isFirstLoad = YES;
    [self hideEmptySeparators];
    
    UIImage* backgroundImage = [UIImage imageNamed:@"blackButton.png"]; 
    UIImage *backgroundButtonImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
    [self.searchButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
    [self.searchButton setTitle:NSLocalizedString(@"Search", @"Search Button") forState:UIControlStateNormal];
    [self.searchButton setTitle:NSLocalizedString(@"Search", @"Search Button") forState:UIControlStateSelected];
    
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [self setTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//DANIEL RIVERA search is broken, fix this.

- (IBAction)searchPlace:(id)sender {
    
    // hide keyboard
    [self.view endEditing: YES];
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://api.geonames.org/searchJSON?country=ch&name_startsWith=%@&featureClass=P&style=FULL&maxRows=12&username=stagend", self.textField.text]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
}

#pragma jsondownloader delegates

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {

    self.isFirstLoad = NO;
    self.places = [JSONParser parsePlaces:data];
    [self.table reloadData];
    [self.Hud hide:YES];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide: YES];
}

#pragma mbprogresshud delegates

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    [self.Hud removeFromSuperview];
    self.Hud = nil;
    
}

#pragma tableview delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.places.count == 0 && !self.isFirstLoad) {
        return 1;
    }
    
    return [self.places count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlaceCell";
    
    PlaceCell *cell = (PlaceCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.places.count == 0) {
        cell.cellView.name.text = NSLocalizedString(@"No results found", @"");
        cell.cellView.state.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    Place *place = [self.places objectAtIndex:indexPath.row];
    cell.cellView.name.text = place.name;
    cell.cellView.state.text = [NSString stringWithFormat:@"%@ (%@)", place.state, place.country];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.places.count > 0) {
        
        Place *place = [self.places objectAtIndex:indexPath.row];
        
        if ([[StagendDB sharedInstance] placeExistsWithId:place.placeId]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"City alredy added", @"") message:NSLocalizedString(@"This city is already present in your favourites list", @"") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
            [alert show];
        }
        else {
            [[StagendDB sharedInstance] AddPlace:place];
        }
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

@end
