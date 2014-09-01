//
//  ConcertsView.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ConcertsView.h"
#import "ConcertDetailsView.h"
#import "Concert.h"
#import "JSONDownloader.h"
#import "JSONParser.h"
#import "ConcertCell.h"
#import "ConcertCellView.h"
#import "StagendDB.h"
#import "JCLLocalNotification.h"
#import "UIImageView+WebCache.h"

@implementation ConcertsView
@synthesize table, editButton, concerts, sections, Hud, noFavouritesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"MyAgenda", @"MyAgenda title");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"") style:UIBarButtonItemStylePlain target:self action:@selector(editBookmarks:)];
        self.navigationItem.rightBarButtonItem = editButton;
        self.tabBarItem.image = [UIImage imageNamed:@"83-calendar"];
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
    
    self.concerts = [[[StagendDB sharedInstance] getConcerts] mutableCopy];
    [self createArrayForNextShowtimes];
    
    if (self.concerts.count == 0) {
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

- (void)editBookmarks:(id)sender {
    
    BOOL edit = !self.table.editing;
    if (edit) {
        [self.editButton setTitle:NSLocalizedString(@"Close", @"")];
    }
    else {
        [self.editButton setTitle:NSLocalizedString(@"Edit", @"")];        
    }
    [self.table setEditing:edit animated:YES];
    
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
    
    
    
}

- (void)showNoFavouritesView {
    
    if (noFavouritesView == nil) {
        noFavouritesView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
        noFavouritesView.backgroundColor = [UIColor clearColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 32.0)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor blackColor];
        label1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0];
        label1.textAlignment = UITextAlignmentCenter;
        label1.text = NSLocalizedString(@"Concert list is empty", @"");
        [noFavouritesView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 75.0, 300.0, 32.0)];
        label2.backgroundColor = [UIColor clearColor];
        label2.numberOfLines = 0;
        label2.textColor = [UIColor blackColor];
        label2.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        label2.textAlignment = UITextAlignmentCenter;
        label2.text = NSLocalizedString(@"Added concerts will be shown here", @"");
        [noFavouritesView addSubview:label2];
        
        UIImageView *cartImage = [[UIImageView alloc] initWithFrame:CGRectMake(146.0, 135.0, 23.0, 25.0)];
        cartImage.image = [UIImage imageNamed:@"83-calendar"];
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
    
    Concert *concert = [JSONParser parseConcert:data];
    
    ConcertDetailsView *concertDetailsView = [[ConcertDetailsView alloc] initWithNibName:@"ConcertDetailsView" bundle:nil];
    concertDetailsView.concert = concert;
    concertDetailsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:concertDetailsView animated:YES];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide: YES];
}

#pragma table delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.sections count];
    
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.concerts objectAtIndex:section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ConcertCell";
    
    ConcertCell *cell = (ConcertCell *) [self.table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ConcertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else {
        // clear contents for reuse 
        [cell.cellView clearContents];
        
    }
    Concert *concert = (Concert *)[[self.concerts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.cellView.title.text = concert.title;
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/140/140", concert.concertId]]placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    //Modified by Daniel Rivera
    
    if ([concert.place length] != 0)
        cell.cellView.place.text = [NSString stringWithFormat:@"%@ - %@", concert.place, concert.city];
    else
        cell.cellView.place.text = [NSString stringWithFormat:@"%@", concert.city];
    [cell.cellView resizeLabelToFitText];
    //
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Concert *concert = [[self.concerts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/eventbyid.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], concert.concertId]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
                
        ConcertDB *c = [[self.concerts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        JCLLocalNotification *notification = [[JCLLocalNotification alloc] init];
        [notification removeNotificationWithID:c.concertId];
        
        [[StagendDB sharedInstance] removeConcert:c];
        
        [[self.concerts objectAtIndex:indexPath.section] removeObject:[[self.concerts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        int totalConcerts = [[StagendDB sharedInstance] countConcerts];
        if (totalConcerts > 0) {
            [(UIViewController *)[self.tabBarController.viewControllers objectAtIndex:4] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", totalConcerts];
        }
        else {
            [(UIViewController *)[self.tabBarController.viewControllers objectAtIndex:4] tabBarItem].badgeValue = nil;
        }
        
        if (totalConcerts == 0) {
            [self performSelector:@selector(showNoFavouritesView) withObject:nil afterDelay:0.5];
        }
        
    }
    
}

@end
