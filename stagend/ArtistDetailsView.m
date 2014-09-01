//
//  ArtistDetailView.m
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistDetailsView.h"
#import "ConcertDetailsView.h"
#import "Concert.h"
#import "JSONParser.h"
#import "ConcertCell.h"
#import "ConcertCellView.h"
#import "Artist.h"
#import "ArtistDB.h"
#import "ArtistDetailsView.h"
#import "UIImageView+WebCache.h"
#import "StagendDB.h"
#import "Member.h"

#import "ArtistConcertsView.h"

@implementation ArtistDetailsView
@synthesize table, imageView, artist, sections, nextBButton, prevBButton, isFromSearch, Hud, artists, currentArtist, noConcerts, addedToFavourites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Concerts", @"Concerts title");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tabBarItem.image = [UIImage imageNamed:@"66-microphone"];
        self.isFromSearch = NO;
        self.currentArtist = 0;
        self.artists = nil;
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
    
    ArtistDB *artistDB = [self.artists objectAtIndex:index];
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/artistbyid.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], artistDB.artistId]];
    
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    [self.Hud show: YES];
    
    
}

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    [self.Hud hide:YES];
    self.prevBButton.enabled = YES;
    self.nextBButton.enabled = YES;
    
    if (self.currentArtist == [self.artists count]-1) {
        //disable button
        self.nextBButton.enabled = NO;
    }
    
    if (self.currentArtist == 0) {
        //disable button
        self.prevBButton.enabled = NO;
    }
    
    self.artist = [JSONParser parseArtist:data];
    self.title = self.artist.name; //rivera
    [self createArrayForNextShowtimes];
    [self.table reloadData];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    
    [self.Hud hide:YES];
    
}

- (void)nextAction:(id)sender {
    
    self.currentArtist = self.currentArtist + 1;
    [self downloadNewDataForIndex:self.currentArtist];
    
}

- (void)prevAction:(id)sender {
    
    self.currentArtist = self.currentArtist - 1;
    [self downloadNewDataForIndex:self.currentArtist];
    
    
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
    toolbar.hidden = YES;
}

- (void)addToFavourites {
    
    
    
    Hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    if ([[StagendDB sharedInstance] artistExistsWithId:self.artist.artistId]) {
        
        Hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"11-x"]];
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.animationType = MBProgressHUDAnimationZoom;
        Hud.labelText = NSLocalizedString(@"Removed", @"");
        Hud.userInteractionEnabled = NO;
        [self.navigationController.view addSubview:Hud];
        [Hud show:YES];
        [Hud hide:YES afterDelay:1.2];
        
        [[StagendDB sharedInstance] removeArtist: [[StagendDB sharedInstance] getArtistById:self.artist.artistId]];
        
        [self.addedToFavourites setHidden: YES];
        
    }
    else {
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/favourite.json", self.artist.artistId]]];
        NSURLConnection *connection = nil;
        connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
        
        Hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"19-check"]];
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.animationType = MBProgressHUDAnimationZoom;
        Hud.labelText = NSLocalizedString(@"Added", @"");
        Hud.userInteractionEnabled = NO;
        [self.navigationController.view addSubview:Hud];
        [Hud show:YES];
        [Hud hide:YES afterDelay:1.2];
        
        [[StagendDB sharedInstance] AddArtist:self.artist];
        
        [self.addedToFavourites setHidden: NO];
        
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.artist.name;
    
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
        if (self.currentArtist == [self.artists count]-1) {
            //disable button
            self.nextBButton.enabled = NO;
        }
        
        if (self.currentArtist == 0) {
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
    
    // check if events are already sorted
    if ([self.artist.events count] > 0) {
        if ([[self.artist.events objectAtIndex:0] isKindOfClass:[NSArray class]]) {
            return;
        }
    }
    
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    NSMutableArray *allShowtimeMutable = [self.artist.events mutableCopy];
    
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
    
    self.artist.events = [NSArray arrayWithArray:temp];
    
    //  [self.noConcerts setHidden: ![self.artist.events count] == 0];
    
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
        
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(7.0, 7.0, 100.0, 100.0);
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/150/150", artist.artistId]]];
        [headerView addSubview:imageView];
        
        //        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 10.0, 190.0, 20.0)];
        //        name.text = self.artist.name;
        //        name.backgroundColor = [UIColor clearColor];
        //        name.font = [UIFont boldSystemFontOfSize:17];
        //        [headerView addSubview:name];
        
        UILabel *genreLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 10.0, 190.0, 12.0)];
        genreLabel.backgroundColor = [UIColor clearColor];
        genreLabel.font = [UIFont systemFontOfSize:12.0];
        genreLabel.textColor = [UIColor grayColor];
        genreLabel.text = NSLocalizedString(@"Genre", @"");
        [headerView addSubview:genreLabel];
        
        UILabel *genre = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 23.0, 190, 12.0)];
        genre.text = self.artist.mainGenre;
        genre.backgroundColor = [UIColor clearColor];
        genre.font = [UIFont systemFontOfSize:12.0];
        genre.lineBreakMode = UILineBreakModeWordWrap;
        genre.numberOfLines = 0;
        [headerView addSubview:genre];
        
        UILabel *genres = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 35.0, 190, 12.0)];
        genres.text = self.artist.genres;
        genres.backgroundColor = [UIColor clearColor];
        genres.font = [UIFont systemFontOfSize:12.0];
        genres.lineBreakMode = UILineBreakModeWordWrap;
        genres.numberOfLines = 0;
        [headerView addSubview:genres];
        
        UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 52.0, 190.0, 12.0)];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.font = [UIFont systemFontOfSize:12.0];
        cityLabel.textColor = [UIColor grayColor];
        cityLabel.text = NSLocalizedString(@"From", @"");
        [headerView addSubview:cityLabel];
        
        UILabel *city = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 65.0, 190.0, 12.0)];
        city.text = self.artist.city;
        city.backgroundColor = [UIColor clearColor];
        city.font = [UIFont systemFontOfSize:12.0];
        [headerView addSubview:city];
        
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
        if ([[StagendDB sharedInstance] artistExistsWithId:artist.artistId]) {
            [self.addedToFavourites setHidden: NO];
        }
        else {
            [self.addedToFavourites setHidden: YES];
        }
        
        
        //modified by DANIEL RIVERA
        
        UIButton *bookThisBandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bookThisBandButton.frame =CGRectMake(128.0, 96.0, 180.0, 40.0);
        [bookThisBandButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
        [bookThisBandButton setTitle:NSLocalizedString(@"Book", @"") forState:UIControlStateNormal];
        bookThisBandButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        
        [bookThisBandButton addTarget:self action:@selector(openBookingURL:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:bookThisBandButton];
        
        
        
        
        
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
        //Daniel Rivera
        if (section == (self.artist.events.count + 1)) {
            headerLabel.text = NSLocalizedString(@"Line up", @"");
        }
        else if (section == (self.artist.events.count + 2))
        {
            headerLabel.text = NSLocalizedString(@"Biography", @"");
        }
        //k
        else
        {
            NSDate *tDate = [self.sections objectAtIndex:section - 1];
            NSDateFormatter *sectionDateFormatter = [[NSDateFormatter alloc] init];
            [sectionDateFormatter setDateStyle:NSDateFormatterFullStyle];
            [sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
            sectionDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
            
            headerLabel.text = [sectionDateFormatter stringFromDate:tDate];
        }
        [headerView addSubview:headerLabel];
        
    }
    
    return headerView;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //Daniel Rivera
    NSInteger *numberOfSections = self.artist.events.count + 3;
    return numberOfSections;
    
    
    //return [self.artist.events count] + 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    //Daniel Rivera
    else if (section == (self.artist.events.count + 1))
    {
        return [self.artist.members count];
    }
    
    else if (section == (self.artist.events.count + 2))
    {
        return 1;
    }
    // k
    else {
        return [[self.artist.events objectAtIndex:section - 1] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Daniel Rivera
    
    if (indexPath.section == 0) {
        
        return nil;
        
    }
    else if (indexPath.section == (self.artist.events.count + 1)) {
        
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackgroundLineup"]];
        }
        
        Member *member = [self.artist.members objectAtIndex:indexPath.row];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", member.name, member.instrument];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    else if(indexPath.section == (self.artist.events.count + 2))
    {
        static NSString *CellIdentifierDescrBio = @"BioCell";
        
        // See if there's an existing cell we can reuse
        UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:CellIdentifierDescrBio];
        if (cell == nil) {
            // No cell to reuse => create a new one
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierDescrBio];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = self.artist.biography;
        return cell;
    }
    
    
    
    
    
    
    
    
    
    
    
    //k
    else{
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
        Concert *concert = (Concert *)[[self.artist.events objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
        cell.cellView.title.text = concert.title;
        [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/140/140", concert.concertId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        //Modified by Daniel Rivera
        if ([concert.place length] != 0)
            cell.cellView.place.text = [NSString stringWithFormat:@"%@ - %@", concert.place, concert.city];
        else
            cell.cellView.place.text = [NSString stringWithFormat:@"%@",concert.city];
        //
        [cell.cellView resizeLabelToFitText];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == (self.artist.events.count + 1))
    {
        
        
        Member *member = [self.artist.members objectAtIndex:indexPath.row];
        NSLog(@"%@", member.memberId);
        [self.table deselectRowAtIndexPath:indexPath animated:NO];
        
        
        
        
    }
    
    
    else{
        ConcertDetailsView *detailView = [[ConcertDetailsView alloc] initWithNibName:@"ConcertDetailsView" bundle:nil];
        Concert *concert = [[self.artist.events objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
        detailView.concert = concert;
        //detailView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
        [self.table deselectRowAtIndexPath:indexPath animated:NO];
    }
}

//Daniel Rivera

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 0.0;
    }
    else if (indexPath.section == (self.artist.events.count + 1))
    {
        return 44.0;
    }
    else  if(indexPath.section == (self.artist.events.count + 2))
    {
        NSString *text = self.artist.biography;
        CGSize constraint = CGSizeMake(300.0f , 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return 35.0 + size.height;
    }
    
    else
    {
        return 80.0;
    }
    
}

-(IBAction)openBookingURL:(id)sender
{
    NSString * URL1 = @"https://www.stagend.com";
    NSString* URL3a = [NSString stringWithFormat: @"%@" , artist.url];
    
    NSString* URL3 = [URL3a substringFromIndex:16];
    
    NSString *URL2 = [NSString stringWithFormat: @"/%@/", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
    
    NSLog(@"%@", URL3);
    NSString * URL4 = @"/contact";
    
    NSString *contactURL = [NSString stringWithFormat: @"%@%@%@%@",URL1, URL2, URL3, URL4];
    
    NSString *contactURLen = [NSString stringWithFormat: @"%@/en/%@%@",URL1, URL3, URL4];
    
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]  isEqual: @"es"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: contactURL]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: contactURLen]];
}





@end
