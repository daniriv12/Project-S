//
//  ArtistDB.h
//  stagend
//
//  Created by Giovanni Iembo on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ArtistDB : NSManagedObject

@property (nonatomic, retain) NSNumber * artistId;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * name;

@end
