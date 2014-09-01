//
//  ConcertsView.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceConcertsView.h"
#import "ConcertDetailsView.h"
#import "Concert.h"
#import "JSONParser.h"
#import "ConcertCell.h"
#import "ConcertCellView.h"
#import "Place.h"
#import "UIImageView+WebCache.h"
#import "StagendDB.h"
#import "JSONParser.h"
#import "PlaceDB.h"
#import "JCLLocationController.h"

@implementation PlaceConcertsView
@synthesize table, imageView, place, sections, mapView, places, currentPlace, Hud, isFromSearch, nextBButton, prevBButton, noConcerts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"66-microphone"];
        self.isFromSearch = NO;
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

- (void)downloadNewDataForIndex:(int)index {
    
    id p = [self.places objectAtIndex:index];
    
    Place *newPlace = [[Place alloc] init];
    
    if ([p isKindOfClass:[PlaceDB class]]) {
        newPlace.placeId = ((PlaceDB *)p).placeId;
        newPlace.name = ((PlaceDB *)p).name;
        newPlace.latitude = ((PlaceDB *)p).latitude;
        newPlace.longitude = ((PlaceDB *)p).longitude;
        [self.places replaceObjectAtIndex:index withObject:newPlace];
    }
    
    Place *nPlace = nil;
    
    if (index == 0) {
        JCLLocationController *locationManager = [JCLLocationController sharedInstance];
        if (![locationManager locationDenied] && [locationManager locationDefined]) {
            CLLocation *currentLocation = [locationManager currentLocation];
            NSLog(@"%@", currentLocation);
            nPlace = [[Place alloc] init];
            nPlace.name = NSLocalizedString(@"Around me", @"");
            nPlace.latitude = [NSNumber numberWithDouble: currentLocation.coordinate.latitude];
            nPlace.longitude = [NSNumber numberWithDouble: currentLocation.coordinate.longitude];
        }
        else {
            UIAlertView *noLocationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Location", @"") message:NSLocalizedString(@"Unable to locate the phone", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [noLocationAlert show];
            return;
        }
    }
    else {
        nPlace = [self.places objectAtIndex:index];
    }
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    
    NSString *latitude = [[NSString stringWithFormat:@"%@", nPlace.latitude] stringByReplacingOccurrencesOfString:@"." withString:@","];
    NSString *longitude = [[NSString stringWithFormat:@"%@", nPlace.longitude] stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    self.place = nPlace;
    
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/%@/%d/eventsfromcoords.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], latitude, longitude, [[NSUserDefaults standardUserDefaults] integerForKey:@"radius"]]];
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
}

- (void)nextAction:(id)sender {
    
    self.currentPlace = self.currentPlace + 1;
    [self downloadNewDataForIndex:self.currentPlace];
    
}

- (void)prevAction:(id)sender {
    
    self.currentPlace = self.currentPlace - 1;
    [self downloadNewDataForIndex:self.currentPlace];
    
}

- (void)addToolBarOption {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.frame = CGRectMake(0.0, 372.0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    self.prevBButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"07-arrow-north"] style:UIBarButtonItemStylePlain target:self action:@selector(prevAction:)];
    [items addObject:self.prevBButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 30.0;
    [items addObject:fixed];
    self.nextBButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"03-arrow-south"] style:UIBarButtonItemStylePlain target:self action:@selector(nextAction:)];
    [items addObject:self.nextBButton];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    [toolbar setItems:items animated:NO];
   // [self.view addSubview:toolbar];
   // self.table.frame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, self.table.frame.size.height-44.0);
}

#pragma jsondownloader delegates
- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    [self.Hud hide:YES];
    
    self.prevBButton.enabled = YES;
    self.nextBButton.enabled = YES;
    
    if (self.currentPlace == [self.places count]-1) {
        //disable button
        self.nextBButton.enabled = NO;
    }
    
    if (self.currentPlace == 0) {
        //disable button
        self.prevBButton.enabled = NO;
    }
    
    self.place.events = [JSONParser parseConcerts:data];
    self.title = self.place.name;
    //Daniel Rivera
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self createArrayForNextShowtimes];
    [self.table reloadData];
    [self setMapPosition];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide: YES];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.table.rowHeight = 80.0;
    self.table.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = self.place.name;
    
    //Daniel Rivera
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.noConcerts = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 150.0, 320.0, 24.0)];
    self.noConcerts.text = @"No concerts";
    self.noConcerts.textAlignment = UITextAlignmentCenter;
    self.noConcerts.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.noConcerts setHidden: YES];
    [self.table addSubview:self.noConcerts];
    
    if (self.isFromSearch) {
        [self downloadNewDataForIndex:0];
    }
    else {
        [self addToolBarOption];
        if (self.currentPlace == [self.places count]-1) {
            //disable button
            self.nextBButton.enabled = NO;
        }
        
        if (self.currentPlace == 0) {
            //disable button
            self.prevBButton.enabled = NO;
        }
        [self createArrayForNextShowtimes];
    }
    
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

- (void)setMapPosition {
    
    MKCoordinateRegion region; 
    MKCoordinateSpan span; 
    span.latitudeDelta = 0.2; 
    span.longitudeDelta = 0.2; 
    
    CLLocationCoordinate2D location; 
    NSLog(@"lat: %@", self.place.latitude);
    location.latitude = [self.place.latitude doubleValue];
    location.longitude = [self.place.longitude doubleValue];
    
    region.span = span;
    region.center = location;
    
    [self.mapView setRegion:region animated: NO]; 
    [self.mapView regionThatFits:region]; 
    [self.mapView addAnnotation:self.place];
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate {
    
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back       
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (void)createArrayForNextShowtimes {
    
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    NSMutableArray *allShowtimeMutable = [self.place.events mutableCopy];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [allShowtimeMutable sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for (Concert *tshowtime in allShowtimeMutable) {
        // Reduce showtime start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate: tshowtime.date];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *showtimesOnThisDay = [sectionDict objectForKey:dateRepresentingThisDay];
        if (showtimesOnThisDay == nil) {
            showtimesOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sectionDict setObject:showtimesOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the showtime to the list for this day
        [showtimesOnThisDay addObject:tshowtime];
        
    }
    
    self.sections = [[sectionDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[self.sections count]];
    for (int i = 0; i < [sections count]; i++) {
        [temp addObject:[sectionDict objectForKey:[sections objectAtIndex:i]]];
    }
    
    self.place.events = [NSArray arrayWithArray:temp];
    
    [self.noConcerts setHidden: ![self.place.events count] == 0];
    
}

#pragma table delegates

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 100.0;
    }
    else {
        return 23.0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (section == 0) {
        
        headerView.frame = CGRectMake(0.0, 0.0, 320.0, 213.0);
        imageView.frame = CGRectMake(20.0, 20.0, 1000.0, 100.0);
        [headerView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 20.0, 300.0, 32.0)];
        name.text = self.place.name;
        name.backgroundColor = [UIColor clearColor];
        [headerView addSubview:name];
        
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 100.0)];
        self.mapView.delegate = self;
        [headerView addSubview: self.mapView]; 
        [NSThread detachNewThreadSelector:@selector(setMapPosition) toTarget:self withObject:nil];
        
    }
    else {
        
        headerView.frame = CGRectMake(0.0, 0.0, 320.0, 23.0);
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header.png"]];
        [headerView addSubview:background];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 23.0);
        
        NSDate *tDate = [self.sections objectAtIndex:section - 1];
        NSDateFormatter *sectionDateFormatter = [[NSDateFormatter alloc] init];
        [sectionDateFormatter setDateStyle:NSDateFormatterFullStyle];
        [sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        sectionDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        headerLabel.text = [sectionDateFormatter stringFromDate:tDate];
        [headerView addSubview:headerLabel];
        
    }
    
    return headerView;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.place.events count] + 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    else {
        return [[self.place.events objectAtIndex:section - 1] count];
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ConcertCell";
    
    ConcertCell *cell = (ConcertCell *) [self.table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ConcertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackground"]];

    }
    else {
        // clear contents for reuse 
        [cell.cellView clearContents];
        
    }
    Concert *concert = (Concert *)[[self.place.events objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
    cell.cellView.title.text = concert.title;
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/150/150", concert.concertId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    //Modified by Daniel Rivera
    if ([concert.place length] != 0)
        cell.cellView.place.text = [NSString stringWithFormat:@"%@ - %@", concert.place, concert.city];
    else
        cell.cellView.place.text = [NSString stringWithFormat:@"%@", concert.city];
    //
    [cell.cellView resizeLabelToFitText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    ConcertDetailsView *detailView = [[ConcertDetailsView alloc] initWithNibName:@"ConcertDetailsView" bundle:nil];
    Concert *concert = [[self.place.events objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
    detailView.concert = concert;
    //detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
    //[detailView release];
    [self.table deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
