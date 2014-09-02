//
//  ConcertDetailsView.m
//  stagend
//
//  Created by Giovanni Iembo on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ConcertDetailsView.h"
#import "StagendDB.h"
#import "Lineup.h"
#import "JCLLocalNotification.h"
#import "LineupCell.h"
#import "LineupCellView.h"
#import "UIImageView+WebCache.h"
#import "ClubDetailsView.h"
#import "JSONDownloader.h"
#import "JSONParser.h"
#import "Club.h"
#import "ArtistDetailsView.h"

#import "DRActivityItemProvider.h"
#import "DRWhatsapp.h"


//Daniel Rivera
#import "ArtistConcertsView.h"


@implementation ConcertDetailsView
@synthesize table, concert, imageView, Hud, addedToFavourites, VenueIsAButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    self.table.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self hideEmptySeparators];
    self.title = self.concert.title;
    //Daniel Rivera
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //
    
    
    //Share button daniel rivera
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButton)];
    
   
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

- (void)addConcert {

    Hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    if ([[StagendDB sharedInstance] concertExistsWithId:concert.concertId]) {
        
        Hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"11-x"]];
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.animationType = MBProgressHUDAnimationZoom;
        Hud.labelText = NSLocalizedString(@"Removed", @"");
        Hud.userInteractionEnabled = NO;
        [self.navigationController.view addSubview:Hud];
        [Hud show:YES];
        [Hud hide:YES afterDelay:1.2];
        
        [[StagendDB sharedInstance] removeConcert: [[StagendDB sharedInstance] getConcertById:self.concert.concertId]];
        
        JCLLocalNotification *notification = [[JCLLocalNotification alloc] init];
        [notification removeNotificationWithID: self.concert.concertId];
        
        [self.addedToFavourites setHidden: YES];
    }
    else {
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/attend.json", self.concert.concertId]]];
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
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"localNotificationEnabled"]) {
            JCLLocalNotification *notification = [[JCLLocalNotification alloc] init];
            NSLog(@"local notification");
            NSDate *date = nil;
            
            //Daniel rivera     
            if (concert.lineup.count > 0) {
               
                NSTimeInterval internal = [((Lineup * )[concert.lineup objectAtIndex:0]).hour timeIntervalSince1970];
                date = [concert.date dateByAddingTimeInterval:internal-60*6];
                NSLog(@"%@", date);
            }
            else {
                
                date = concert.date;
            }
            
            [notification addNotificationWithID:concert.concertId andWithAlertMessagge:concert.title andWithTime:date];
        }
        else {
            NSLog(@"no local notification");
        }
        [[StagendDB sharedInstance] AddConcert:self.concert];
        
        [self.addedToFavourites setHidden: NO];
    }
    
    [(UIViewController *)[self.tabBarController.viewControllers objectAtIndex:4] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", [[StagendDB sharedInstance] countConcerts]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

}

- (void)showClubDetails {
    
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    jsonDownloader.typeJSON = 0;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%@/clubbyid.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], self.concert.clubId]];
    
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    
    [self.view addSubview:self.Hud];
    
    self.Hud.delegate = self;
    [self.Hud show: YES];
    
    
}

- (void)showArtistDetailWithID:(int)artistId {
    
    JSONDownloader *jsonDownloader = [[JSONDownloader alloc] init];
    jsonDownloader.delegate = self;
    jsonDownloader.typeJSON = 1;
    [jsonDownloader get:[NSString stringWithFormat:@"http://www.stagend.com/api/%@/%d/artistbyid.json", [[NSUserDefaults standardUserDefaults] objectForKey:@"language"], artistId]];
    
    self.Hud = [[MBProgressHUD alloc] initWithView: self.view];
    [self.view addSubview:self.Hud];
    self.Hud.delegate = self;
    [self.Hud show: YES];

}

#pragma jsondownloader delegates

- (void)downloadDidFinish:(JSONDownloader *)jsonDownloader data:(NSDictionary *)data {
    
    [self.Hud hide: YES];

    if (jsonDownloader.typeJSON == 0) {
        
        
        
        //Daniel Rivera  hacky fix but should work. all data entries contain one element, but full ones usually contain 1,000+ chars
        // whereas empty ones contain >30
        if (data.description.length > 100)
        {
            NSLog(@"lalalalala");
            NSLog(@"%i", data.count);
            NSLog(@"%i", data.description.length);
        Club *club = [JSONParser parseClub:data]; //CRASH HAPPENS HERE
        
        
        ClubDetailsView *clubDetailsView = [[ClubDetailsView alloc] initWithNibName:@"ClubDetailsView" bundle:nil];
        clubDetailsView.club = club;
        [self.navigationController pushViewController:clubDetailsView animated:YES];
        }
        //Daniel Rivera
        else{
            
            
            Hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            
            Hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"11-x"]];
            Hud.mode = MBProgressHUDModeCustomView;
            Hud.animationType = MBProgressHUDAnimationZoom;
            Hud.labelText = NSLocalizedString(@"Action not possible.", @"");
            Hud.userInteractionEnabled = NO;
            [self.navigationController.view addSubview:Hud];
            [Hud show:YES];
            [Hud hide:YES afterDelay:1.2];
            //do a toast that simply says "Woops! action not available for this venue"
        }
        
            
    }
    else {
        Artist *artist = [JSONParser parseArtist:data];
        
        
        //DANIEL RIVERA
  //      ArtistDetailsView *artistDetailView = [[ArtistDetailsView alloc] initWithNibName:@"ArtistDetailsView" bundle:nil];
  //      artistDetailView.artist = artist;
  //      [self.navigationController pushViewController:artistDetailView animated:YES];
        
        ArtistConcertsView *artistConcertsView = [[ArtistConcertsView alloc] initWithNibName:@"ArtistConcertsView" bundle:nil];
        artistConcertsView.artist = artist;
        artistConcertsView.isFromConcert = YES;
        [self.navigationController pushViewController:artistConcertsView animated:YES];
        
        //k
    }
    
    
}

- (void)handleConnectionError:(JSONDownloader *)jsonDownloader {
    [self.Hud hide: YES];
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
        [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/100/100", concert.concertId]]];
        [headerView addSubview:imageView];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 10.0, 190.0, 20.0)];
        title.text = self.concert.title;
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:17];
        [headerView addSubview:title];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 45.0, 190.0, 12.0)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.text = NSLocalizedString(@"Date", @"");
        [headerView addSubview:dateLabel];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"E dd LLLL YYYY"];
        dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 58.0, 190.0, 12.0)];
        date.text = [dateFormat stringFromDate:concert.date];
        date.backgroundColor = [UIColor clearColor];
        date.font = [UIFont systemFontOfSize:12.0];
        [headerView addSubview:date];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 75.0, 190.0, 12.0)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:12.0];
        priceLabel.textColor = [UIColor grayColor];
        priceLabel.text = NSLocalizedString(@"Price", @"");
        [headerView addSubview:priceLabel];
        
        NSLocale* ita = [[NSLocale alloc] initWithLocaleIdentifier:@"it_CH"];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:ita];
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 88.0, 190.0, 12.0)];
        price.font = [UIFont systemFontOfSize:12.0];
        
        if ([concert.price floatValue] > 0.0) {
            price.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:concert.price]];
        }
        else if ([concert.price floatValue] == 0.0) {
            price.text = NSLocalizedString(@"Free", @"");
        }
        else {
            price.text = NSLocalizedString(@"Not specified", @"");
        }

        price.backgroundColor = [UIColor clearColor];
        [headerView addSubview:price];
        
        UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 105.0, 190.0, 12.0)];
        placeLabel.backgroundColor = [UIColor clearColor];
        placeLabel.font = [UIFont systemFontOfSize:12.0];
        placeLabel.textColor = [UIColor grayColor];
        placeLabel.text = NSLocalizedString(@"Venue", @"");
        [headerView addSubview:placeLabel];
        
        
        
        UILabel *place = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 118.0, 190.0, 12.0)];
        //From here on modified by Daniel Rivera
        
        //Bug: if the venue of the concer is not specified, upon requesting to follow the location of the event the app crashes.
        //Fixed now.
        
        
        if ([concert.place length] != 0)
            place.text = [NSString stringWithFormat:@"%@ - %@", concert.place, concert.city];
        else
            place.text = [NSString stringWithFormat:@"%@", concert.city];
        place.backgroundColor = [UIColor clearColor];
        
        
        place.font = [UIFont systemFontOfSize:12.0];
        [headerView addSubview:place];
        
        
        if ([concert.place length] != 0 ){
        UIButton *detailsBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        detailsBackgroundButton.frame = CGRectMake(120.0, 100.0, 200.0, 30.0);
        detailsBackgroundButton.backgroundColor = [UIColor clearColor];
        [detailsBackgroundButton addTarget:self action:@selector(showClubDetails) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:detailsBackgroundButton];
      
        UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"]];
        disclosure.frame = CGRectMake(300.0, 118.0, 9.0, 13.0);
        [headerView addSubview:disclosure];
        
        }
        
       //Modified up to here by Daniel Rivera
        
        
        
        
        
        
        
        UIImage* backgroundImage = [UIImage imageNamed:@"blackButton.png"]; 
        UIImage *backgroundButtonImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
        
        UIButton *addToFavouritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addToFavouritesButton.frame = CGRectMake(8.0, 112.0, 100.0, 24.0);
        [addToFavouritesButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
        [addToFavouritesButton setTitle:NSLocalizedString(@"Remind me", @"") forState:UIControlStateNormal];
        addToFavouritesButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [addToFavouritesButton addTarget:self action:@selector(addConcert) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:addToFavouritesButton];
        
        self.addedToFavourites = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"19-greencheck"]];
        self.addedToFavourites.frame = CGRectMake(90.0, 115.0, 12.0, 14.0);
        [headerView addSubview: self.addedToFavourites];
        if ([[StagendDB sharedInstance] concertExistsWithId:concert.concertId]) {
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
        headerLabel.frame = CGRectMake(28.0, 0.0, 320.0, 23.0);
        if (section == 1) {
            headerLabel.text = NSLocalizedString(@"Line up", @"");
        }
        else {
            headerLabel.text = NSLocalizedString(@"Presentation", @"");
        }
        
        [headerView addSubview:headerLabel];
        
    }
    
    return headerView;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    else if (section == 1) {
        return [self.concert.lineup count];
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 0.0;
    }
    else if (indexPath.section == 1) {
        return 55.0;
    }
    else {
        NSString *text = self.concert.descr;
        CGSize constraint = CGSizeMake(300.0f , 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return 35.0 + size.height;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return nil;
    }
    else if (indexPath.section == 1) {
        static NSString *CellIdentifierLineup = @"LineupCell";
        
        LineupCell *cell = (LineupCell *) [self.table dequeueReusableCellWithIdentifier:CellIdentifierLineup];
        if (cell == nil) {
            cell = [[LineupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLineup];
            
        }
        else {
            // clear contents for reuse 
            //[cell.cellView clearContents];
            
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        Lineup *lineup = [self.concert.lineup objectAtIndex:indexPath.row];
        [cell.cellView.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/138/138", lineup.artistId]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        NSLog(@"%@",lineup.artistId);
        cell.cellView.artistName.text = lineup.artistName;
        cell.cellView.date.text = [dateFormat stringFromDate:lineup.hour];
        cell.cellView.genre.text = lineup.genre;
        
        return cell;
        
    }
    else {
        static NSString *CellIdentifierDescr = @"CellDescr";
        
        // See if there's an existing cell we can reuse
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDescr];
        if (cell == nil) {
            // No cell to reuse => create a new one
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierDescr];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.textLabel.text = self.concert.descr;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        Lineup *lineup = [self.concert.lineup objectAtIndex:indexPath.row];
        [self showArtistDetailWithID:[lineup.artistId intValue]];
    }
    
    [self.table deselectRowAtIndexPath:indexPath animated:NO];
    
}


//Daniel Rivera


- (IBAction)shareButton
{
    
    
    

    NSString * URL1 = @"https://www.stagend.com/event/";
    NSString * URL2 = [NSString stringWithFormat:@"%@%@",URL1,self.concert.concertId];
    
    
    NSURL *website = [NSURL URLWithString:URL2];
    
    

   
    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/event/%@/100/100", concert.concertId]];
    
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    
    
    
    
    NSString* text = [NSString stringWithFormat:@"%@ %@",website, @"#StagendConcert"];
    
    DRActivityItemProvider *twitTXT = [[DRActivityItemProvider alloc] initWithDefaultText:text];
    DRActivityImageProvider *twitIMG = [[DRActivityImageProvider alloc] initWithDefaultImage:image];
    DRActivityURLProvider *twitURL =[[DRActivityURLProvider alloc] initWithDefaultURL:website];
    
    //TEXT for whatsapp message goes here
    NSString* whatsappMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Sharing concert", @""), website];
    WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:whatsappMessage forABID:nil];
    
    
    
    
    
    NSArray *objectsToShare = @[twitTXT, twitIMG, twitURL,whatsappMsg];
    
    
    
    NSArray *applicationActivities = @[[[DRWhatsapp alloc] init]];
  
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:applicationActivities];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeCopyToPasteboard];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
