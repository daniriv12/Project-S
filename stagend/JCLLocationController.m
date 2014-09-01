//
//  JCLLocationController.m
//  Allison
//
//  Created by koa on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JCLLocationController.h"


@implementation JCLLocationController

@synthesize locationManager, currentLocation, locationDenied, locationDefined;

static JCLLocationController *sharedInstance;

+ (JCLLocationController *)sharedInstance
{
    static JCLLocationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JCLLocationController alloc] init];
    });
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (id) init {
    self = [super init];    
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void) showAlertForEnableLocationServices {
	UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Services Disabled", @"") message:NSLocalizedString(@"Turn on the 'Location Service' of your iPhone (Settings -> Location Services), to be able to find concerts around you.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
	[servicesDisabledAlert show];
}

-(void)reset
{
	locationDefined = NO;
    currentLocation = nil;
}

- (void) startUpdates {
	
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; 
        self.locationManager.distanceFilter = 10.0;
        [self.locationManager startUpdatingLocation];
    }
	else if ([CLLocationManager locationServicesEnabled]) {
		self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10.0;
		[self.locationManager startUpdatingLocation];
	}
	else {
        locationDenied = YES;
		[self showAlertForEnableLocationServices];
	}
    locationDefined = NO;
    currentLocation = nil;
	
}

- (void) stopUpdates
{
	if (self.locationManager)
	{
		[self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
	}
	[self reset];
}

- (BOOL) locationServicesEnabled
{
	return [CLLocationManager locationServicesEnabled];
}

- (NSString *) getPinWithAddress:(NSString *)address {
    
    NSString *placeAddress = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", placeAddress];
    
    return urlString;
    
}

- (NSString *) getPinWithCoordinate:(CLLocation *)coord andPinName:(NSString * )pinName {
    
    NSString *placeName = [pinName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@@%f,%f", placeName, coord.coordinate.latitude, coord.coordinate.longitude];
    
    return urlString;
    
}

- (NSString *) getCurrentLocationMapDirectionUrlToDestionationCoord:(CLLocationCoordinate2D)coord {

    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%f,%f&saddr=%f,%f", coord.latitude, coord.longitude, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    
    return urlString;

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    locationDenied = NO;
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {     
        self.currentLocation = newLocation;
        locationDefined = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"locationChanged" object:nil];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [self reset];
    
	switch([error code])
	{
		case kCLErrorNetwork:{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Error", @"") message:NSLocalizedString(@"please check your network connection or that you are not in airplane mode", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil, nil];
			[alert show];
		}
			break;
		case kCLErrorDenied:{
            locationDenied = YES;
            [self stopUpdates];
			/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"user has denied to use current Location " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];*/
		}
			break;
            
        case kCLErrorHeadingFailure:{
            locationDenied = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Error", @"") message:NSLocalizedString(@"Magnetic Field Interference, please move away from the magnetic disturbance.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil];
            [alert show];
        }
            break;
		default:{
			/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Default" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];*/
		}
			break;
	}

}

@end
