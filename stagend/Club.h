//
//  Club.h
//  stagend
//
//  Created by Giovanni Iembo on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Club : NSObject <MKAnnotation> {
@private
    CLLocationCoordinate2D coordinate;
}

@property (strong, nonatomic) NSNumber *clubId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *genre;
@property (strong, nonatomic) NSNumber * latitude;
@property (strong, nonatomic) NSNumber * longitude;
@property (strong, nonatomic) NSArray *events;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end