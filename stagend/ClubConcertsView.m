//
//  ConcertsView.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClubConcertsView.h"
#import "ConcertDetailsView.h"
#import "ClubDetailsView.h"
#import "Concert.h"
#import "JSONParser.h"
#import "ConcertCell.h"
#import "ConcertCellView.h"
#import "Club.h"
#import "ClubDB.h"
#import "UIImageView+WebCache.h"
#import "StagendDB.h"

@implementation ClubConcertsView
@synthesize table, imageView, club, sections, nextBButton, prevBButton, clubs, currentClub, Hud, isFromSearch, noConcerts, addedToFavourites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Concerts", @"Concerts title");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        self.tabBarItem.image = [UIImage imageNamed:@"66-microphone"];
        self.isFromSearch = NO;
        self.clubs = nil;
        self.currentClub = 0;
        self.prevBButton = nil;
        self.nextBButton = nil;
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
    
    ClubDB *clubDB = [self.clubs objectAtIndex:index];

    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/clubbyid.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], clubDB.clubId]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    [self.Hud show: YES];
    
}

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    [self.Hud hide:YES];
    self.prevBButton.enabled = YES;
    self.nextBButton.enabled = YES;
    
    if (self.currentClub == [self.clubs count]-1) {
        //disable button
        self.nextBButton.enabled = NO;
    }
    
    if (self.currentClub == 0) {
        //disable button
        self.prevBButton.enabled = NO;
    }
    
    self.club = [JSONParser parseClub:data];
    [self createArrayForNextShowtimes];
    [self.table reloadData];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    
    [self.Hud hide:YES];
    
}

- (void)nextAction:(id)sender {
    
    self.currentClub = self.currentClub + 1;
    [self downloadNewDataForIndex:self.currentClub];
    
}

- (void)prevAction:(id)sender {
    
    self.currentClub = self.currentClub - 1;
    [self downloadNewDataForIndex:self.currentClub];
    
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
    [self.view addSubview:toolbar];
    self.table.frame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, self.table.frame.size.height-44.0);
}

- (void)addToFavourites {
    
    Hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    if ([[StagendDB sharedInstance] clubExistsWithId:self.club.clubId]) {
        
        Hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"11-x"]];
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.animationType = MBProgressHUDAnimationZoom;
        Hud.labelText = NSLocalizedString(@"Removed", @"");
        Hud.userInteractionEnabled = NO;
        [self.navigationController.view addSubview:Hud];
        [Hud show:YES];
        [Hud hide:YES afterDelay:1.2];
        
        [[StagendDB sharedInstance] removeClub: [[StagendDB sharedInstance] getClubById:self.club.clubId]];
        
        [self.addedToFavourites setHidden: YES];
        
    }
    else {
        
        Hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"19-check"]];
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.animationType = MBProgressHUDAnimationZoom;
        Hud.labelText = NSLocalizedString(@"Added", @"");
        Hud.userInteractionEnabled = NO;
        [self.navigationController.view addSubview:Hud];
        [Hud show:YES];
        [Hud hide:YES afterDelay:1.2];
        
        [[StagendDB sharedInstance] AddClub:self.club];
        
        [self.addedToFavourites setHidden: NO];
        
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.table.rowHeight = 80.0;
    self.table.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.noConcerts = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 150.0, 320.0, 24.0)];
    self.noConcerts.text = NSLocalizedString(@"No concerts", @"");
    self.noConcerts.textAlignment = UITextAlignmentCenter;
    self.noConcerts.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.noConcerts setHidden: YES];
    [self.table addSubview:self.noConcerts];
    
    if (!self.isFromSearch) {
        [self addToolBarOption];
        if (self.currentClub == [self.clubs count]-1) {
            //disable button
            self.nextBButton.enabled = NO;
        }
        
        if (self.currentClub == 0) {
            //disable button
            self.prevBButton.enabled = NO;
        }
    }
    
    [self createArrayForNextShowtimes];
    
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

- (void)clubDetails {
    
    ClubDetailsView *clubDetailsView = [[ClubDetailsView alloc] initWithNibName:@"ClubDetailsView" bundle:nil];
    clubDetailsView.club = self.club;
    [self.navigationController pushViewController:clubDetailsView animated:YES];
    
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
    
    if ([self.club.events count] > 0) {
        if ([[self.club.events objectAtIndex:0] isKindOfClass:[NSArray class]]) {
            return;
        }
    }
    
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    NSMutableArray *allShowtimeMutable = [self.club.events mutableCopy];
    
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
    
    self.club.events = [NSArray arrayWithArray:temp];
    NSLog(@"%d", [self.club.events count]);
    [self.noConcerts setHidden: ![self.club.events count] == 0];
    
}

#pragma table delegates

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 140.0;
    }
    else {
        return 23.0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (section == 0) {
        
        headerView.frame = CGRectMake(0.0, 0.0, 320.0, 140.0);
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackgroundHeader2"]];
        backgroundView.frame = CGRectMake(0.0, 0.0, 320.0, 140.0);
        [headerView addSubview:backgroundView];
        
        UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        detailsButton.frame = CGRectMake(300.0, 65.0, 9.0, 13.0);
        [detailsButton setImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
        [detailsButton addTarget:self action:@selector(clubDetails) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:detailsButton];
        
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(7.0, 7.0, 100.0, 100.0);
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/150/150", club.clubId]]];
        [headerView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 10.0, 190.0, 20.0)];
        name.text = self.club.name;
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont boldSystemFontOfSize:17];
        [headerView addSubview:name];
        
        UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 45.0, 190.0, 12.0)];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.font = [UIFont systemFontOfSize:12.0];
        cityLabel.textColor = [UIColor grayColor];
        cityLabel.text = NSLocalizedString(@"City", @"");
        [headerView addSubview:cityLabel];
        
        UILabel *city = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 58.0, 190.0, 16.0)];
        city.text = self.club.city;
        city.backgroundColor = [UIColor clearColor];
        city.font = [UIFont systemFontOfSize:12.0];
        [headerView addSubview:city];
        
        UIButton *actionDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionDetailsButton.frame = CGRectMake(0.0, 0.0, 320.0, 100.0);
        actionDetailsButton.backgroundColor = [UIColor clearColor];
        [actionDetailsButton addTarget:self action:@selector(clubDetails) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:actionDetailsButton];
        
        UIImage* backgroundImage = [UIImage imageNamed:@"blackButton.png"]; 
        UIImage *backgroundButtonImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
        
        UIButton *addToFavouritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addToFavouritesButton.frame = CGRectMake(8.0, 112.0, 100.0, 24.0);
        [addToFavouritesButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
        [addToFavouritesButton setTitle:NSLocalizedString(@"Favourite", @"") forState:UIControlStateNormal];
        addToFavouritesButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [addToFavouritesButton addTarget:self action:@selector(addToFavourites) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:addToFavouritesButton];
        
        self.addedToFavourites = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"19-greencheck"]];
        self.addedToFavourites.frame = CGRectMake(90.0, 115.0, 12.0, 14.0);
        [headerView addSubview: self.addedToFavourites];
        if ([[StagendDB sharedInstance] clubExistsWithId:club.clubId]) {
            [self.addedToFavourites setHidden: NO];
        }
        else {
            [self.addedToFavourites setHidden: YES];
        }
        
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
    
    return [self.club.events count] + 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    else {
        return [[self.club.events objectAtIndex:section - 1] count];
    }
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
    
    Concert *concert = (Concert *)[[self.club.events objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
    cell.cellView.title.text = concert.title;
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/140/140", concert.concertId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    //Modified by Daniel Rivera
    if ([concert.place length] != 0)
        cell.cellView.place.text = [NSString stringWithFormat:@"%@ - %@", concert.place, concert.city];
    else
        cell.cellView.place.text = [NSString stringWithFormat:@"%@", concert.city];
    //
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    ConcertDetailsView *detailView = [[ConcertDetailsView alloc] initWithNibName:@"ConcertDetailsView" bundle:nil];
    Concert *concert = [[self.club.events objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
    detailView.concert = concert;
    //detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
    //[detailView release];
    [self.table deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
