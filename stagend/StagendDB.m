//
//  StagendDB.m
//  stagend
//
//  Created by Giovanni Iembo on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StagendDB.h"

@implementation StagendDB

+ (StagendDB *)sharedInstance {
    
    static StagendDB *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StagendDB alloc] init];
    });
    return sharedInstance;
    
}

- (id)init {
    self = [super initWithDBName:@"Stagend"];
    if (self) {
        // perform initialization of object here
    }
    return self;
}

#pragma mark artist

- (BOOL)artistExistsWithId:(NSNumber *)artistId {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ArtistDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artistId == %@", artistId];
    
    [request setPredicate:predicate];
	
    NSError *error = nil;
    
    NSUInteger count = [moc countForFetchRequest:request error:&error];
    
    if (count > 0) {
        return YES;
    }
    
    return NO;

}

- (void)AddArtist:(Artist *)artist {
    
    ArtistDB *artistDB = (ArtistDB *) [NSEntityDescription insertNewObjectForEntityForName:@"ArtistDB" inManagedObjectContext:super.managedObjectContext];
    artistDB.artistId = artist.artistId;
    artistDB.genre = artist.mainGenre;
    artistDB.name = artist.name;    
    
    [super saveContext];
    
}

- (NSArray *)getArtists {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ArtistDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSSortDescriptor* nameDescription = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
	NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:nameDescription, nil];
    
    [request setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return data;
    
}

- (ArtistDB *)getArtistById:(NSNumber *)artistId {
 
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ArtistDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artistId == %@", artistId];
    
    [request setPredicate:predicate];
    
    [request setEntity:entityDescription];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return [data objectAtIndex: 0];
}

- (void)removeArtist:(ArtistDB *)artist {
    
    NSError *error;
    [self.managedObjectContext deleteObject:artist];
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error deleting %@ - error:%@",entity,error);
    }
    
}

#pragma mark concert

- (BOOL)concertExistsWithId:(NSNumber *)concertId {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConcertDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"concertId == %@", concertId];
    
    [request setPredicate:predicate];
	
    NSError *error = nil;
    
    NSUInteger count = [moc countForFetchRequest:request error:&error];
    
    if (count > 0) {
        return YES;
    }
    
    return NO;
    
}

- (void)AddConcert:(ConcertDB *)concert {
    
    ConcertDB *concertDB = (ConcertDB *) [NSEntityDescription insertNewObjectForEntityForName:@"ConcertDB" inManagedObjectContext:super.managedObjectContext];
    concertDB.concertId = concert.concertId;
    concertDB.title = concert.title;
    concertDB.date = concert.date;
    concertDB.place = concert.place;
    concertDB.city = concert.city;
    
    [super saveContext];
    
}

- (void)removeOldConcerts {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConcertDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    NSLog(@"%@", [[NSDate date] dateByAddingTimeInterval:-24*60*60]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date < %@", [[NSDate date] dateByAddingTimeInterval:-24*60*60]];
    
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray* items = [moc executeFetchRequest:request error:&error];
    
    for (NSManagedObject * item in items) {
        [self.managedObjectContext deleteObject:item];
    }
    [self saveContext];
}

- (NSArray *)getConcerts {
    
    [self removeOldConcerts];
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConcertDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSSortDescriptor* nameDescription = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
	NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:nameDescription, nil];
    
    [request setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return data;
    
}

- (ConcertDB *)getConcertById:(NSNumber *)concertId {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConcertDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"concertId == %@", concertId];
    
    [request setPredicate:predicate];
    
    [request setEntity:entityDescription];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return [data objectAtIndex: 0];
    
}

- (void)removeConcert:(ConcertDB *)concert {
    NSError *error;
    [self.managedObjectContext deleteObject:concert];
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error deleting %@ - error:%@",entity,error);
    }
    
}

- (NSUInteger)countConcerts {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConcertDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSError *error = nil;
    
    return [moc countForFetchRequest:request error:&error];
    
}

#pragma mark club

- (BOOL)clubExistsWithId:(NSNumber *)clubId {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ClubDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clubId == %@", clubId];
    
    [request setPredicate:predicate];
	
    NSError *error = nil;
    
    NSUInteger count = [moc countForFetchRequest:request error:&error];
    
    if (count > 0) {
        return YES;
    }
    
    return NO;
    
}

- (void)AddClub:(Club *)club {
    
    ClubDB *clubDB = (ClubDB *) [NSEntityDescription insertNewObjectForEntityForName:@"ClubDB" inManagedObjectContext:super.managedObjectContext];
    clubDB.clubId = club.clubId;
    clubDB.name = club.name;
    clubDB.city = club.city;
    
    [super saveContext];
    
}

- (NSArray *)getClubs {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ClubDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSSortDescriptor* nameDescription = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
	NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:nameDescription, nil];
    
    [request setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return data;
    
}

- (ClubDB *)getClubById:(NSNumber *)clubId {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ClubDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clubId == %@", clubId];
    
    [request setPredicate:predicate];
    
    [request setEntity:entityDescription];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return [data objectAtIndex: 0];
}

- (void)removeClub:(ClubDB *)club {
    
    NSError *error;
    [self.managedObjectContext deleteObject:club];
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error deleting %@ - error:%@",entity,error);
    }
    
}

#pragma mark place

- (BOOL)placeExistsWithId:(NSNumber *)placeId {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"PlaceDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeId == %@", placeId];
    
    [request setPredicate:predicate];
	
    NSError *error = nil;
    
    NSUInteger count = [moc countForFetchRequest:request error:&error];
    
    if (count > 0) {
        return YES;
    }
    
    return NO;
    
}

- (void)AddPlace:(Place *)place {
    
    PlaceDB *placeDB = (PlaceDB *) [NSEntityDescription insertNewObjectForEntityForName:@"PlaceDB" inManagedObjectContext:super.managedObjectContext];
    placeDB.placeId = place.placeId;
    placeDB.name = place.name;
    placeDB.state = place.state;
    placeDB.country = place.country;
    placeDB.latitude = place.latitude;
    placeDB.longitude = place.longitude;
    
    [super saveContext];
    
}

- (NSArray *)getPlaces {
    
    NSManagedObjectContext *moc = super.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"PlaceDB" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
	
    NSSortDescriptor* nameDescription = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
	NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:nameDescription, nil];
    
    [request setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    
    NSArray* data = [moc executeFetchRequest:request error:&error];
    
    if (data == nil) {
        NSLog(@"%@", error);
    }
	
    return data;
    
}

- (void)removePlace:(PlaceDB *)place {
    
    NSError *error;
    [self.managedObjectContext deleteObject:place];
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error deleting %@ - error:%@",entity,error);
    }
    
}

@end
