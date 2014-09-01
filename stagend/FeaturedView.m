//
//  FeaturedView.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FeaturedView.h"
#import "ConcertDetailsView.h"
#import "Concert.h"
#import "JSONDownloader.h"
#import "JSONParser.h"
#import "ConcertCell.h"
#import "ConcertCellView.h"
#import "UIImageView+WebCache.h"

@implementation FeaturedView
@synthesize table, concerts, sections, Hud, appSettingsViewController, noConcerts, lastFeaturedUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Featured", @"Featured title");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        //Refresh button for featured page
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(download)];
        //Settings button
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
        
        //The Featured option on the bottom tab
        self.tabBarItem.image = [UIImage imageNamed:@"14-tag"];
        self.lastFeaturedUpdate = nil;
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
    
    self.noConcerts = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 150.0, 320.0, 24.0)];
    self.noConcerts.text = NSLocalizedString(@"No concerts", @"");
    self.noConcerts.textAlignment = UITextAlignmentCenter;
    self.noConcerts.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.noConcerts setHidden: YES];
    [self.table addSubview:self.noConcerts];
    
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
    
    NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:self.lastFeaturedUpdate]);
    // Update every 4 h
    if (self.lastFeaturedUpdate == nil) {
        [self download];
    }
    else if ([[NSDate date] timeIntervalSinceDate:self.lastFeaturedUpdate] > 4*60) {
        [self download];
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

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}

- (void)openSettings {
    
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    aNavController.navigationBar.barStyle = UIBarStyleBlack;
    self.appSettingsViewController.showDoneButton = YES;
    self.appSettingsViewController.showCreditsFooter = NO;
    [self presentModalViewController:aNavController animated:YES];
    
}

- (void)download {
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/featuredevents.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"]]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
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
    NSMutableArray *allShowtimeMutable = [self.concerts mutableCopy];
    
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
    
    self.concerts = [NSArray arrayWithArray:temp];
    
    [self.noConcerts setHidden: ![self.concerts count] == 0];
    
}

#pragma mark IASKAppSettingsViewControllerDelegate protocol

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
}

#pragma mark jsondownloader delegates

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    self.concerts = [JSONParser parseConcerts:data];
    [self createArrayForNextShowtimes];
    [self.table reloadData];
    [self.Hud hide:YES];
    self.lastFeaturedUpdate = [NSDate date];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide:YES];
}

#pragma mark mbprogresshud delegates

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    [self.Hud removeFromSuperview];
    self.Hud = nil;
    
}

#pragma table delegates

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 23.0;
        
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 23.0)];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header.png"]];
    [headerView addSubview:background];    
    
    NSDate *tDate = [self.sections objectAtIndex:section];
    NSDateFormatter *sectionDateFormatter = [[NSDateFormatter alloc] init];
    [sectionDateFormatter setDateStyle:NSDateFormatterFullStyle];
    [sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    sectionDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    headerLabel.frame = CGRectMake(10.0, 0.0, 310.0, 23.0);
    headerLabel.text = [sectionDateFormatter stringFromDate:tDate];
    [headerView addSubview:headerLabel];
    
    return headerView;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [self.sections count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.concerts objectAtIndex:section] count];
    
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

    Concert *concert = (Concert *)[[self.concerts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.cellView.title.text = concert.title;
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/138/138", concert.concertId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    //Modified by Daniel Rivera
    if ([concert.place length] !=0)
        cell.cellView.place.text = [NSString stringWithFormat:@"%@ - %@", concert.place, concert.city];
    else
        cell.cellView.place.text = [NSString stringWithFormat:@"%@", concert.city];
    [cell.cellView resizeLabelToFitText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ConcertDetailsView *detailView = [[ConcertDetailsView alloc] initWithNibName:@"ConcertDetailsView" bundle:nil];
    Concert *concert = [[self.concerts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    detailView.concert = concert;
    detailView.hidesBottomBarWhenPushed = YES;
    //detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
    //[detailView release];
    [self.table deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
