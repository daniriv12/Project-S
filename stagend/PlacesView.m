//
//  PlansView.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesView.h"
#import "JSONDownloader.h"
#import "JSONParser.h"
#import "SearchPlaceView.h"
#import "StagendDB.h"
#import "Place.h"
#import "PlaceConcertsView.h"
#import "JCLLocationController.h"
#import "PlaceCell.h"
#import "PlaceCellView.h"

@implementation PlacesView
@synthesize table, addPlanButton, places, Hud, selectedPlace, selectedIndex, noFavouritesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Cities", @"City title");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.addPlanButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlace:)];
        self.navigationItem.rightBarButtonItem = addPlanButton;
        self.tabBarItem.image = [UIImage imageNamed:@"60-signpost"];
        self.selectedPlace = [[Place alloc] init];
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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.table.rowHeight = 80.0;
    self.table.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self hideEmptySeparators];
   
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.places = [[[StagendDB sharedInstance] getPlaces] mutableCopy];
  
    Place *place = [[Place alloc] init];
    place.placeId = [[NSNumber alloc] initWithInt: -1];
    place.name = NSLocalizedString(@"Around me", @"");

    [self.places insertObject:(PlaceDB *)place atIndex:0];
    
    if (self.places.count == 1) {
        [self showNoFavouritesView];
    }
    else {
        [self removeNoFavouritesView];
    }
    
    [table reloadData];
    
}

- (void)viewDidUnload
{
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

- (void)addPlace:(id)sender {
    
    // Stop scrolling the table
    [self.table setContentOffset:CGPointMake(self.table.contentOffset.x, self.table.contentOffset.y) animated:NO];
    
    SearchPlaceView *searchPlaceView = [[SearchPlaceView alloc] initWithNibName:@"SearchPlaceView" bundle:nil];
    [self.navigationController pushViewController:searchPlaceView animated:YES];

    
}

- (void)showNoFavouritesView {
    
    if (noFavouritesView == nil) {
        noFavouritesView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100.0, self.view.frame.size.width, self.view.frame.size.height - 100.0)];
        noFavouritesView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, 320.0, 32.0)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor blackColor];
        label1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
        label1.textAlignment = UITextAlignmentCenter;
        
        label1.text = NSLocalizedString(@"City list is empty", @"");
        [noFavouritesView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 125.0, 300.0, 32.0)];
        label2.backgroundColor = [UIColor clearColor];
        label2.numberOfLines = 0;
        label2.textColor = [UIColor blackColor];
        label2.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        label2.textAlignment = UITextAlignmentCenter;
        label2.text = NSLocalizedString(@"Added cities will be shown here", @"");
        [noFavouritesView addSubview:label2];
        
        UIImageView *cartImage = [[UIImageView alloc] initWithFrame:CGRectMake(146.0, 185.0, 22.0, 28.0)];
        cartImage.image = [UIImage imageNamed:@"60-signpost"];
        [noFavouritesView addSubview:cartImage];
        
        [self.view addSubview:noFavouritesView];
        
    }
    
}

- (void)removeNoFavouritesView {
    
    [noFavouritesView removeFromSuperview];
    noFavouritesView = nil;
    
}

#pragma jsondownloader delegates
- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
       
    [self.Hud hide:YES];
    
    self.selectedPlace.events = [JSONParser parseConcerts:data];
    
    PlaceConcertsView *placeConcertsView = [[PlaceConcertsView alloc] initWithNibName:@"PlaceConcertsView" bundle:nil];
    placeConcertsView.place = self.selectedPlace;
    placeConcertsView.places = [self.places mutableCopy];
    placeConcertsView.currentPlace = self.selectedIndex;
    placeConcertsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:placeConcertsView animated:YES];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide: YES];
}

#pragma table delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlaceCell";
    
    PlaceCell *cell = (PlaceCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Place *place = [self.places objectAtIndex:indexPath.row];
    cell.cellView.name.text = place.name;
    if (indexPath.row > 0) {
        cell.cellView.state.text = [NSString stringWithFormat:@"%@ (%@)", place.state, place.country];
    }
    else {
        cell.cellView.state.text = @"";
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PlaceDB *placeDB = [self.places objectAtIndex:indexPath.row]; 
    self.selectedIndex = indexPath.row;
    if (indexPath.row == 0) {
        JCLLocationController *locationManager = [JCLLocationController sharedInstance];
        if (![locationManager locationDenied] && [locationManager locationDefined]) {
            CLLocation *currentLocation = [locationManager currentLocation];
            NSLog(@"%@", currentLocation);
            self.selectedPlace.latitude = [NSNumber numberWithDouble: currentLocation.coordinate.latitude];
            self.selectedPlace.longitude = [NSNumber numberWithDouble: currentLocation.coordinate.longitude];
            self.selectedPlace.name = NSLocalizedString(@"Around me", @"");
        }
        else {
            UIAlertView *noLocationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Location", @"") message:NSLocalizedString(@"Unable to locate the phone", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [noLocationAlert show];
            [self.table deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
    }
    else {
        self.selectedPlace.placeId = placeDB.placeId;
        self.selectedPlace.name = placeDB.name;
        self.selectedPlace.latitude = placeDB.latitude;
        self.selectedPlace.longitude = placeDB.longitude;
    }
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    
    NSString *latitude = [[NSString stringWithFormat:@"%@", self.selectedPlace.latitude] stringByReplacingOccurrencesOfString:@"." withString:@","];
    NSString *longitude = [[NSString stringWithFormat:@"%@", self.selectedPlace.longitude] stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/%@/%d/eventsfromcoords.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], latitude, longitude, [[NSUserDefaults standardUserDefaults] integerForKey:@"radius"]]];
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row > 0;
    
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[StagendDB sharedInstance] removePlace:[self.places objectAtIndex:indexPath.row]];
        
        [self.places removeObject:[self.places objectAtIndex:indexPath.row]];
        
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (self.places.count == 1) {
            [self performSelector:@selector(showNoFavouritesView) withObject:nil afterDelay:0.5];
        }
        
    }
    
}

@end
