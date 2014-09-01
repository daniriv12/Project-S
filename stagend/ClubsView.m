//
//  ClubsView.m
//  stagend
//
//  Created by Claudio Di Giacinto on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClubsView.h"
#import "SearchClubView.h"
#import "Club.h"
#import "StagendDB.h"
#import "ClubConcertsView.h"
#import "JSONParser.h"
#import "ClubCell.h"
#import "ClubCellView.h"
#import "UIImageView+WebCache.h"

@implementation ClubsView
@synthesize table, Hud, clubs, selectedIndex, noFavouritesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Clubs", @"Clubs title");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClub:)];
        self.tabBarItem.image = [UIImage imageNamed:@"07-map-marker"];
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
    [self hideEmptySeparators];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.clubs = [[[StagendDB sharedInstance] getClubs] mutableCopy];
    
    if (self.clubs.count == 0) {
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

- (void)addClub:(id)sender {
    
    // Stop scrolling the table
    [self.table setContentOffset:CGPointMake(self.table.contentOffset.x, self.table.contentOffset.y) animated:NO];
    
    SearchClubView *searchClubView = [[SearchClubView alloc] initWithNibName:@"SearchClubView" bundle:nil];
    [self.navigationController pushViewController:searchClubView animated:YES];
    
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
        label1.text = NSLocalizedString(@"Club list is empty", @"");
        [noFavouritesView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 75.0, 300.0, 32.0)];
        label2.backgroundColor = [UIColor clearColor];
        label2.numberOfLines = 0;
        label2.textColor = [UIColor blackColor];
        label2.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        label2.textAlignment = UITextAlignmentCenter;
        label2.text = NSLocalizedString(@"Added clubs will be shown here", @"");
        [noFavouritesView addSubview:label2];
        
        UIImageView *cartImage = [[UIImageView alloc] initWithFrame:CGRectMake(152.0, 135.0, 16.0, 26.0)];
        cartImage.image = [UIImage imageNamed:@"07-map-marker"];
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
    
    Club *club = [JSONParser parseClub:data];
    
    ClubConcertsView *clubConcertsView = [[ClubConcertsView alloc] initWithNibName:@"ClubConcertsView" bundle:nil];
    clubConcertsView.hidesBottomBarWhenPushed = YES;
    clubConcertsView.isFromSearch = NO;
    clubConcertsView.club = club;
    clubConcertsView.clubs = self.clubs;
    clubConcertsView.currentClub = self.selectedIndex;
    [self.navigationController pushViewController:clubConcertsView animated:YES];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    
}

#pragma table delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.clubs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ClubCell";
    
    ClubCell *cell = (ClubCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ClubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else {
        [cell.cellView clearContents];
    }
    
    ClubDB *club = (ClubDB *)[self.clubs objectAtIndex:indexPath.row];
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/140/140", club.clubId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.cellView.name.text = club.name;
    cell.cellView.city.text = club.city;
    [cell.cellView resizeLabelToFitText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Club *club = [self.clubs objectAtIndex:indexPath.row];
    
    self.selectedIndex = indexPath.row;
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/clubbyid.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], club.clubId]];
    
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
        
        [[StagendDB sharedInstance] removeClub:[self.clubs objectAtIndex:indexPath.row]];
        
        [self.clubs removeObject:[self.clubs objectAtIndex:indexPath.row]];
        
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (self.clubs.count == 0) {
            [self performSelector:@selector(showNoFavouritesView) withObject:nil afterDelay:0.5];
        }
        
    }
    
}

@end
