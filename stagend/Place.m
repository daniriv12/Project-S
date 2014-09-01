//
//  Place.m
//  stagend
//
//  Created by Giovanni Iembo on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize placeId;
@synthesize name;
@synthesize state;
@synthesize country;
@synthesize latitude;
@synthesize longitude;
@synthesize events;

- (CLLocationCoordinate2D)coordinate {
    
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    
    return coordinate;
    
}

@end
