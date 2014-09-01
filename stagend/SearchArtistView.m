//
//  SearchArtistView.m
//  stagend
//
//  Created by Giovanni Iembo on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchArtistView.h"
#import "JSONParser.h"
#import "StagendDB.h"
#import "Artist.h"
#import "ArtistCell.h"
#import "ArtistCellView.h"
#import "UIImageView+WebCache.h"
#import "ArtistConcertsView.h"

@implementation SearchArtistView
@synthesize textField, tableView, searchButton, artists, Hud, isFirstLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search artist", @"");
        //Daniel Rivera
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //above line makes search work
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
    [self.tableView setTableFooterView:v];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 80.0;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
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
    [self setTableView:nil];
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)searchArtist:(id)sender {
    
    // hide keyboard
    [self.view endEditing: YES];
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/artist.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], self.textField.text]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
}

#pragma jsondownloader delegates

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    self.isFirstLoad = NO;
    self.artists = [JSONParser parseArtists:data];
    [self.tableView reloadData];
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

    if (self.artists.count == 0 && !self.isFirstLoad) {
        return 1;
    }
    
    return [self.artists count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ArtistCell";
    
    ArtistCell *cell = (ArtistCell *) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ArtistCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.artists.count == 0) {
        cell.cellView.logo.image = nil;
        cell.cellView.name.text = NSLocalizedString(@"No results found", @"");
        cell.cellView.genre.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    Artist *artist = (Artist *)[self.artists objectAtIndex:indexPath.row];
    cell.cellView.name.text = artist.name;
    [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/150/150", artist.artistId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.cellView.genre.text = artist.mainGenre;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.artists.count > 0) {
        
        Artist *artist = [self.artists objectAtIndex:indexPath.row];
        
        ArtistConcertsView *concertsView = [[ArtistConcertsView alloc] initWithNibName:@"ArtistConcertsView" bundle:nil];
        concertsView.isFromSearch = YES;
        concertsView.artist = artist;
        [self.navigationController pushViewController:concertsView animated:YES];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    
}

@end
