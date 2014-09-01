//
//  SearchClubView.m
//  stagend
//
//  Created by Giovanni Iembo on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchClubView.h"
#import "JSONParser.h"
#import "Club.h"
#import "StagendDB.h"
#import "ClubCell.h"
#import "ClubCellView.h"
#import "UIImageView+WebCache.h"
#import "ClubConcertsView.h"

@implementation SearchClubView
@synthesize table, textField, searchButton, clubs, Hud, isFirstLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search club", @"");
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

- (IBAction)searchClub:(id)sender {
    
    // hide keyboard
    [self.view endEditing: YES];
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/club.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], self.textField.text]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
}

#pragma jsondownloader delegates

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    self.isFirstLoad = NO;
    self.clubs = [JSONParser parseClubs:data];
    [self.table reloadData];
    [self.Hud hide:YES];
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide:YES];
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
    
    if (self.clubs.count == 0 && !self.isFirstLoad) {
        return 1;
    }
    
    return [self.clubs count];

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ClubCell";
    
    ClubCell *cell = (ClubCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ClubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.clubs.count == 0) {
        cell.cellView.logo.image = nil;
        cell.cellView.name.text = NSLocalizedString(@"No results found", @"");
        cell.cellView.city.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    Club *club = (Club *)[self.clubs objectAtIndex:indexPath.row];
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/150/150", club.clubId]]placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.cellView.name.text = club.name;
    cell.cellView.city.text = club.city;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.clubs.count > 0) {
        Club *club = [self.clubs objectAtIndex:indexPath.row];
        
        ClubConcertsView *clubConcertsView = [[ClubConcertsView alloc] initWithNibName:@"ClubConcertsView" bundle:nil];
        clubConcertsView.isFromSearch = YES;
        clubConcertsView.club = club;
        [self.navigationController pushViewController:clubConcertsView animated:YES];
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    
}

@end
