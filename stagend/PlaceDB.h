//
//  PlaceDB.h
//  stagend
//
//  Created by Giovanni Iembo on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlaceDB : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * placeId;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;

@end
