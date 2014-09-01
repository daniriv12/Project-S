//
//  JSONParser.h
//  stagend
//
//  Created by Giovanni Iembo on 05.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Concert;
@class Artist;
@class Club;
@class Place;

@interface JSONParser : NSObject

+ (NSArray *) parseConcerts:(NSDictionary *)data;
+ (Concert *) parseConcert:(NSDictionary *)data;

+ (NSArray *) parseArtists:(NSDictionary *)data;
+ (Artist *) parseArtist:(NSDictionary *)data;

+ (NSArray *) parseClubs:(NSDictionary *)data;
+ (Club *) parseClub:(NSDictionary *)data;

+ (NSArray *) parsePlaces:(NSDictionary *)data;

@end
