//
//  Club.m
//  stagend
//
//  Created by Giovanni Iembo on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Club.h"

@implementation Club

@synthesize clubId, name, street, city, country, genre, latitude, longitude, events;

- (CLLocationCoordinate2D)coordinate {
    
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    
    return coordinate;
    
}

@end
