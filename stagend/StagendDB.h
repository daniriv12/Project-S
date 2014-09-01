//
//  StagendDB.h
//  stagend
//
//  Created by Giovanni Iembo on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Database.h"
#import "ArtistDB.h"
#import "Artist.h"
#import "ConcertDB.h"
#import "Concert.h"
#import "ClubDB.h"
#import "Club.h"
#import "PlaceDB.h"
#import "Place.h"

@interface StagendDB : Database

+ (StagendDB *)sharedInstance;

- (BOOL)artistExistsWithId:(NSNumber *)artistId;
- (void)AddArtist:(Artist *)artist;
- (NSArray *)getArtists;
- (ArtistDB *)getArtistById:(NSNumber *)artistId;
- (void)removeArtist:(ArtistDB *)artist;

- (BOOL)concertExistsWithId:(NSNumber *)concertId;
- (void)AddConcert:(Concert *)concert;
- (NSArray *)getConcerts;
- (ConcertDB *)getConcertById:(NSNumber *)concertId;
- (void)removeConcert:(ConcertDB *)concert;
- (NSUInteger)countConcerts;

- (BOOL)clubExistsWithId:(NSNumber *)clubId;
- (void)AddClub:(Club *)club;
- (NSArray *)getClubs;
- (ClubDB *)getClubById:(NSNumber *)clubId;
- (void)removeClub:(ClubDB *)club;

- (BOOL)placeExistsWithId:(NSNumber *)placeId;
- (void)AddPlace:(Place *)place;
- (NSArray *)getPlaces;
- (void)removePlace:(PlaceDB *)place;

@end
