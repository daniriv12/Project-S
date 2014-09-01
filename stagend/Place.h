//
//  Place.h
//  stagend
//
//  Created by Giovanni Iembo on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Place : NSObject <MKAnnotation> {
@private
    CLLocationCoordinate2D coordinate;
}

@property (strong, nonatomic) NSNumber * placeId;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * state;
@property (strong, nonatomic) NSString * country;
@property (strong, nonatomic) NSNumber * latitude;
@property (strong, nonatomic) NSNumber * longitude;
@property (strong, nonatomic) NSArray *events;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
