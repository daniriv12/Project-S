//
//  ClubDetailView.m
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClubDetailsView.h"
#import "Club.h"
#import "Concert.h"
#import "StagendDB.h"
#import "JCLLocationController.h"
#import "UIImageView+WebCache.h"

@implementation ClubDetailsView

@synthesize imageView, name, genre, address, city, mapView, addToFavouritesButton, club, Hud, openInMaps, addedToFavourites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.club.name;
    //Daniel Rivera
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.stagend.com/image/profile/%@/100/100", club.clubId]]];
    self.name.text = self.club.name;
    self.genre.text = self.club.genre;
    self.address.text = self.club.street;
    self.city.text = club.city;
    
    UIImage* backgroundImage = [UIImage imageNamed:@"blackButton.png"]; 
    UIImage *backgroundButtonImage = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
    
    [self.addToFavouritesButton setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
    [self.openInMaps setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
    
    if ([[StagendDB sharedInstance] clubExistsWithId:club.clubId]) {
        [self.addedToFavourites setHidden: NO];
    }
    else {
        [self.addedToFavourites setHidden: YES];
    }
    
    [NSThread detachNewThreadSelector:@selector(setMapPosition) toTarget:self withObject:nil]; 
    
}

- (void)viewDidUnload {

    [self setName:nil];
    [self setGenre:nil];
    [self setAddress:nil];
    [self setCity:nil];
    [self setImageView:nil];
    [self setMapView:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)addToFavourites:(id)sender {

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

- (void)setMapPosition {
    
    MKCoordinateRegion region; 
    MKCoordinateSpan span; 
    span.latitudeDelta = 0.2; 
    span.longitudeDelta = 0.2; 
    
    CLLocationCoordinate2D location; 
    location.latitude = [self.club.latitude doubleValue];
    location.longitude = [self.club.longitude doubleValue];
    
    region.span = span;
    region.center = location;
    
    [self.mapView setRegion:region animated: NO]; 
    [self.mapView regionThatFits:region]; 
    [self.mapView addAnnotation:self.club];
}

- (IBAction)openMaps:(id)sender {
    
    CLLocation *clubLocation = [[CLLocation alloc] initWithLatitude:[self.club.latitude floatValue] longitude:[self.club.longitude floatValue]];
    NSString *linkMap = [[JCLLocationController sharedInstance] getPinWithCoordinate:clubLocation andPinName:self.club.name];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkMap]];
    
}

@end
