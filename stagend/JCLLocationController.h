//
//  JCLLocationController.h
//  Allison
//
//  Created by koa on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface JCLLocationController : NSObject <CLLocationManagerDelegate> 

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (readonly) BOOL locationDenied;
@property (readonly) BOOL locationDefined;

- (BOOL) locationServicesEnabled;
+ (JCLLocationController *)sharedInstance;
- (void) startUpdates;
- (void) stopUpdates;
- (BOOL) locationDefined;
- (BOOL) locationDenied;
- (NSString *) getPinWithCoordinate:(CLLocation *)coord andPinName:(NSString * )pinName;
- (NSString *) getCurrentLocationMapDirectionUrlToDestionationCoord:(CLLocationCoordinate2D)coord;

@end
