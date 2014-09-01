//
//  JSONParser.m
//  stagend
//
//  Created by Giovanni Iembo on 05.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONParser.h"
#import "Concert.h"
#import "Lineup.h"
#import "Artist.h"
#import "Member.h"
#import "Club.h"
#import "Place.h"

@implementation JSONParser

+ (NSArray *) parseConcerts:(NSDictionary *)data {

    NSMutableArray *_data = [NSMutableArray array];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];

    NSArray *entries = [data objectForKey:@"event"];

    for (int i = 0; i < [entries count]; i++) {
        NSDictionary *entry = [entries objectAtIndex: i];
        Concert *concert = [[Concert alloc] init];
        concert.concertId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"id"] intValue]];
        concert.url = [entry objectForKey:@"url"];
        concert.imageName = [entry objectForKey:@"image"];
        concert.title = [entry objectForKey:@"title"];
        concert.descr = [entry objectForKey:@"description"];
        concert.image = [entry objectForKey:@"image"];
        concert.date = [format dateFromString:[entry objectForKey:@"date"]];
        if (![[entry objectForKey:@"price"] isEqualToString:@""]) {
            concert.price = [[NSNumber alloc] initWithFloat:[[entry objectForKey:@"price"] floatValue]];
        }
        else {
            concert.price = [[NSNumber alloc] initWithFloat:-1.0];
        }
        concert.clubId = [entry objectForKey:@"club_id"];
        concert.place = [entry objectForKey:@"club"];
        concert.street = [entry objectForKey:@"street"];
        concert.city = [entry objectForKey:@"city"];
        concert.zip = [entry objectForKey:@"zip"];
        
        NSArray *lineup_ = [entry objectForKey:@"lineup"];
        NSMutableArray *concertLineup = [[NSMutableArray alloc] init];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"H:m:s"];
        format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];

        for (int j= 0; j < [lineup_ count]; j++) {
            
            NSDictionary *lineupEntry = [lineup_ objectAtIndex: j];
            Lineup *lineup = [[Lineup alloc] init];
            lineup.artistId = [[NSNumber alloc] initWithInt:[[lineupEntry objectForKey:@"profile_id"] intValue]];
            lineup.artistName = [lineupEntry objectForKey:@"name"];
            lineup.hour = [format dateFromString:[lineupEntry objectForKey:@"hour"]];
            lineup.description = [lineupEntry objectForKey:@"description"];
            lineup.genre = [lineupEntry objectForKey:@"genre_main"];
            
            [concertLineup addObject:lineup];
        }
        concert.lineup = concertLineup;
        
        [_data addObject:concert];
    }
    return [_data copy];

    
}

+ (Concert *) parseConcert:(NSDictionary *)data {
    
    NSArray *entry2 = [data objectForKey:@"event"];
    NSDictionary *entry = [entry2 objectAtIndex:0];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
        format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];

        Concert *concert = [[Concert alloc] init];
        concert.concertId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"id"] intValue]];
        concert.url = [entry objectForKey:@"url"];
        concert.imageName = [entry objectForKey:@"image"];
        concert.title = [entry objectForKey:@"title"];
        concert.descr = [entry objectForKey:@"description"];
        NSLog(@"%@", [entry objectForKey:@"description"]);
        concert.image = [entry objectForKey:@"image"];
        concert.date = [format dateFromString:[entry objectForKey:@"date"]];
        if (![[entry objectForKey:@"price"] isEqualToString:@""]) {
            concert.price = [[NSNumber alloc] initWithFloat:[[entry objectForKey:@"price"] floatValue]];
        }
        else {
            concert.price = [[NSNumber alloc] initWithFloat:-1.0];
        }
        concert.clubId = [entry objectForKey:@"club_id"];
        concert.place = [entry objectForKey:@"club"];
        concert.street = [entry objectForKey:@"street"];
        concert.city = [entry objectForKey:@"city"];
        concert.zip = [entry objectForKey:@"zip"];
        
        NSArray *lineup_ = [entry objectForKey:@"lineup"];
        NSMutableArray *concertLineup = [[NSMutableArray alloc] init];
        
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        [format2 setDateFormat:@"H:m:s"];
    format2.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        for (int j= 0; j < [lineup_ count]; j++) {
            
            NSDictionary *lineupEntry = [lineup_ objectAtIndex: j];
            Lineup *lineup = [[Lineup alloc] init];
            lineup.artistId = [[NSNumber alloc] initWithInt:[[lineupEntry objectForKey:@"profile_id"] intValue]];
            lineup.artistName = [lineupEntry objectForKey:@"name"];
            lineup.hour = [format2 dateFromString:[lineupEntry objectForKey:@"hour"]];
            lineup.description = [lineupEntry objectForKey:@"description"];
            lineup.genre = [lineupEntry objectForKey:@"genre_main"];
            
            [concertLineup addObject:lineup];
        }
        concert.lineup = concertLineup;
        
    return concert;
    
}

+ (NSArray *) parseArtists:(NSDictionary *)data {
    
    NSMutableArray *_data = [NSMutableArray array];
    
    NSArray *entries = [data objectForKey:@"artist"];
    
    for (int i = 0; i < [entries count]; i++) {
        NSDictionary *entry = [entries objectAtIndex:i];
        
        Artist *artist = [[Artist alloc] init];
        artist.artistId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"profile_id"] intValue]];
        artist.name = [entry objectForKey:@"name"];
        artist.city = [entry objectForKey:@"city"];
        artist.mainGenre = [entry objectForKey:@"genre_main"];
        artist.genres = [entry objectForKey:@"genre"];
        artist.biography = [entry objectForKey:@"biography"];
        artist.url = [entry objectForKey:@"url"];
        
        NSArray *members = [entry objectForKey:@"members"];
        NSMutableArray *artistMembers = [[NSMutableArray alloc] init];
        
        for (int j= 0; j < [members count]; j++) {
            
            NSDictionary *artistMember = [members objectAtIndex: j];
            Member *member = [[Member alloc] init];
            member.memberId = [[NSNumber alloc] initWithInt:[[artistMember objectForKey:@"profile_id"] intValue]];
            member.name = [artistMember objectForKey:@"name"];
            member.instrument = [artistMember objectForKey:@"instrument"];            
            
            [artistMembers addObject:member];
        }
        artist.members = artistMembers;
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        NSArray *events = [entry objectForKey:@"events"];
        NSMutableArray *artistEvents = [[NSMutableArray alloc] init];
        
        for (int j= 0; j < [events count]; j++) {
            
            NSDictionary *entry2 = [events objectAtIndex: j];
            Concert *concert = [[Concert alloc] init];
            concert.concertId = [[NSNumber alloc] initWithInt:[[entry2 objectForKey:@"id"] intValue]];
            concert.url = [entry2 objectForKey:@"url"];
            concert.imageName = [entry2 objectForKey:@"image"];
            concert.title = [entry2 objectForKey:@"title"];
            concert.descr = [entry2 objectForKey:@"description"];
            concert.image = [entry2 objectForKey:@"image"];
            concert.date = [format dateFromString:[entry2 objectForKey:@"date"]];        
            if (![[entry objectForKey:@"price"] isEqualToString:@""]) {
                concert.price = [[NSNumber alloc] initWithFloat:[[entry2 objectForKey:@"price"] floatValue]];
            }
            else {
                concert.price = [[NSNumber alloc] initWithFloat:-1.0];
            }
            concert.clubId = [entry2 objectForKey:@"club_id"];
            concert.place = [entry2 objectForKey:@"club"];
            concert.street = [entry2 objectForKey:@"street"];
            concert.city = [entry2 objectForKey:@"city"];
            concert.zip = [entry2 objectForKey:@"zip"];
            
            NSArray *lineup_ = [entry2 objectForKey:@"lineup"];
            NSMutableArray *concertLineup = [[NSMutableArray alloc] init];
            
            NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
            [format2 setDateFormat:@"H:m:s"];
            format2.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
            
            for (int j= 0; j < [lineup_ count]; j++) {
                NSDictionary *lineupEntry = [lineup_ objectAtIndex: j];
                Lineup *lineup = [[Lineup alloc] init];
                lineup.artistId = [[NSNumber alloc] initWithInt:[[lineupEntry objectForKey:@"profile_id"] intValue]];
                lineup.artistName = [lineupEntry objectForKey:@"name"];
                lineup.hour = [format2 dateFromString:[lineupEntry objectForKey:@"hour"]];
                lineup.description = [lineupEntry objectForKey:@"description"];
                lineup.genre = [lineupEntry objectForKey:@"genre_main"];
                
                [concertLineup addObject:lineup];
            }
            concert.lineup = concertLineup;
            
            [artistEvents addObject:concert];
        }
        artist.events = artistEvents;
        
        [_data addObject:artist];
    }
    return [_data copy];
    
}

+ (Artist *) parseArtist:(NSDictionary *)data {
    
    NSArray *entry2 = [data objectForKey:@"artist"];
    NSDictionary *entry = [entry2 objectAtIndex:0];
    
    Artist *artist = [[Artist alloc] init];
    artist.artistId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"profile_id"] intValue]];
    artist.name = [entry objectForKey:@"name"];
    artist.city = [entry objectForKey:@"city"];
    artist.mainGenre = [entry objectForKey:@"genre_main"];
    artist.genres = [entry objectForKey:@"genre"];
    artist.biography = [entry objectForKey:@"biography"];
    artist.url = [entry objectForKey:@"url"];
    
    NSArray *members = [entry objectForKey:@"members"];
    NSMutableArray *artistMembers = [[NSMutableArray alloc] init];
    
    for (int j= 0; j < [members count]; j++) {
        
        NSDictionary *artistMember = [members objectAtIndex: j];
        Member *member = [[Member alloc] init];
        member.memberId = [[NSNumber alloc] initWithInt:[[artistMember objectForKey:@"profile_id"] intValue]];
        member.name = [artistMember objectForKey:@"name"];
        member.instrument = [artistMember objectForKey:@"instrument"];            
        
        [artistMembers addObject:member];
    }
    artist.members = artistMembers;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
    
    NSArray *events = [entry objectForKey:@"events"];
    NSMutableArray *artistEvents = [[NSMutableArray alloc] init];
    
    for (int j= 0; j < [events count]; j++) {
        
        NSDictionary *entry2 = [events objectAtIndex: j];
        Concert *concert = [[Concert alloc] init];
        concert.concertId = [[NSNumber alloc] initWithInt:[[entry2 objectForKey:@"id"] intValue]];
        concert.url = [entry2 objectForKey:@"url"];
        concert.imageName = [entry2 objectForKey:@"image"];
        concert.title = [entry2 objectForKey:@"title"];
        concert.descr = [entry2 objectForKey:@"description"];
        concert.image = [entry2 objectForKey:@"image"];
        concert.date = [format dateFromString:[entry2 objectForKey:@"date"]];        
        if (![[entry objectForKey:@"price"] isEqualToString:@""]) {
            concert.price = [[NSNumber alloc] initWithFloat:[[entry2 objectForKey:@"price"] floatValue]];
        }
        else {
            concert.price = [[NSNumber alloc] initWithFloat:-1.0];
        }
        concert.clubId = [entry2 objectForKey:@"club_id"];
        concert.place = [entry2 objectForKey:@"club"];
        concert.street = [entry2 objectForKey:@"street"];
        concert.city = [entry2 objectForKey:@"city"];
        concert.zip = [entry2 objectForKey:@"zip"];
        
        NSArray *lineup_ = [entry2 objectForKey:@"lineup"];
        NSMutableArray *concertLineup = [[NSMutableArray alloc] init];
        
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        [format2 setDateFormat:@"H:m:s"];
        format2.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        for (int j= 0; j < [lineup_ count]; j++) {
            NSDictionary *lineupEntry = [lineup_ objectAtIndex: j];
            Lineup *lineup = [[Lineup alloc] init];
            lineup.artistId = [[NSNumber alloc] initWithInt:[[lineupEntry objectForKey:@"profile_id"] intValue]];
            lineup.artistName = [lineupEntry objectForKey:@"name"];
            lineup.hour = [format2 dateFromString:[lineupEntry objectForKey:@"hour"]];
            lineup.description = [lineupEntry objectForKey:@"description"];
            lineup.genre = [lineupEntry objectForKey:@"genre_main"];
            
            [concertLineup addObject:lineup];
        }
        concert.lineup = concertLineup;
        
        [artistEvents addObject:concert];
    }
    artist.events = artistEvents;
    
    
    return artist;
    
}

+ (NSArray *) parseClubs:(NSDictionary *)data {
    
    NSMutableArray *_data = [NSMutableArray array];
    
    NSArray *entries = [data objectForKey:@"club"];
    
    for (int i = 0; i < [entries count]; i++) {
        NSDictionary *entry = [entries objectAtIndex:i];
        
        Club *club = [[Club alloc] init];
        club.clubId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"profile_id"] intValue]];
        club.name = [entry objectForKey:@"name"];
        club.street = [entry objectForKey:@"street"];
        club.city = [entry objectForKey:@"city"];
        club.country = [entry objectForKey:@"country"];
        club.genre = [entry objectForKey:@"genre"];
        club.latitude = [NSNumber numberWithDouble: [[entry objectForKey:@"lat"] doubleValue]];
        club.longitude = [NSNumber numberWithDouble: [[entry objectForKey:@"lng"] doubleValue]];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        NSArray *events = [entry objectForKey:@"events"];
        NSMutableArray *clubEvents = [[NSMutableArray alloc] init];
        
        for (int i= 0; i < [events count]; i++) {
            
            NSDictionary *entry2 = [events objectAtIndex: i];
            Concert *concert = [[Concert alloc] init];
            concert.concertId = [[NSNumber alloc] initWithInt:[[entry2 objectForKey:@"id"] intValue]];
            concert.url = [entry2 objectForKey:@"url"];
            concert.imageName = [entry2 objectForKey:@"image"];
            concert.title = [entry2 objectForKey:@"title"];
            concert.descr = [entry2 objectForKey:@"description"];
            concert.image = [entry2 objectForKey:@"image"];
            concert.date = [format dateFromString:[entry2 objectForKey:@"date"]];
            if (![[entry objectForKey:@"price"] isEqualToString:@""]) {
                concert.price = [[NSNumber alloc] initWithFloat:[[entry2 objectForKey:@"price"] floatValue]];
            }
            else {
                concert.price = [[NSNumber alloc] initWithFloat:-1.0];
            }
            concert.clubId = [entry2 objectForKey:@"club_id"];
            concert.place = [entry2 objectForKey:@"club"];
            concert.street = [entry2 objectForKey:@"street"];
            concert.city = [entry2 objectForKey:@"city"];
            concert.zip = [entry2 objectForKey:@"zip"];
            
            NSArray *lineup_ = [entry2 objectForKey:@"lineup"];
            NSMutableArray *concertLineup = [[NSMutableArray alloc] init];
            
            NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
            [format2 setDateFormat:@"H:m:s"];
            format2.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
            
            for (int j= 0; j < [lineup_ count]; j++) {
                NSDictionary *lineupEntry = [lineup_ objectAtIndex: j];
                Lineup *lineup = [[Lineup alloc] init];
                lineup.artistId = [[NSNumber alloc] initWithInt:[[lineupEntry objectForKey:@"id"] intValue]];
                lineup.artistName = [lineupEntry objectForKey:@"name"];
                lineup.hour = [format2 dateFromString:[lineupEntry objectForKey:@"hour"]];
                lineup.description = [lineupEntry objectForKey:@"description"];
                lineup.genre = [lineupEntry objectForKey:@"genre_main"];
                
                [concertLineup addObject:lineup];
            }
            concert.lineup = concertLineup;
            
            [clubEvents addObject:concert];
        }
        club.events = clubEvents;
        
        [_data addObject:club];
    }
    return [_data copy];
    
}

+ (Club *) parseClub:(NSDictionary *)data {
    
    NSArray *entry2 = [data objectForKey:@"club"];
    NSDictionary *entry = [entry2 objectAtIndex:0];
    
    Club *club = [[Club alloc] init];
    club.clubId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"profile_id"] intValue]];
    club.name = [entry objectForKey:@"name"];
    club.street = [entry objectForKey:@"street"];
    club.city = [entry objectForKey:@"city"];
    club.country = [entry objectForKey:@"country"];
    club.genre = [entry objectForKey:@"genre"];
    club.latitude = [NSNumber numberWithDouble: [[entry objectForKey:@"lat"] doubleValue]];
    club.longitude = [NSNumber numberWithDouble: [[entry objectForKey:@"lng"] doubleValue]];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    format.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
    
    NSArray *events = [entry objectForKey:@"events"];
    NSMutableArray *clubEvents = [[NSMutableArray alloc] init];
    
    for (int i= 0; i < [events count]; i++) {
        
        NSDictionary *entry2 = [events objectAtIndex: i];
        Concert *concert = [[Concert alloc] init];
        concert.concertId = [[NSNumber alloc] initWithInt:[[entry2 objectForKey:@"id"] intValue]];
        concert.url = [entry2 objectForKey:@"url"];
        concert.imageName = [entry2 objectForKey:@"image"];
        concert.title = [entry2 objectForKey:@"title"];
        concert.descr = [entry2 objectForKey:@"description"];
        concert.image = [entry2 objectForKey:@"image"];
        concert.date = [format dateFromString:[entry2 objectForKey:@"date"]];
        if (![[entry objectForKey:@"price"] isEqualToString:@""]) {
            concert.price = [[NSNumber alloc] initWithFloat:[[entry2 objectForKey:@"price"] floatValue]];
        }
        else {
            concert.price = [[NSNumber alloc] initWithFloat:-1.0];
        }
        concert.clubId = [entry2 objectForKey:@"club_id"];
        concert.place = [entry2 objectForKey:@"club"];
        concert.street = [entry2 objectForKey:@"street"];
        concert.city = [entry2 objectForKey:@"city"];
        concert.zip = [entry2 objectForKey:@"zip"];

        NSArray *lineup_ = [entry2 objectForKey:@"lineup"];
        NSMutableArray *concertLineup = [[NSMutableArray alloc] init];
        
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        [format2 setDateFormat:@"H:m:s"];
        format2.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"language"]];
        
        for (int j= 0; j < [lineup_ count]; j++) {
            NSDictionary *lineupEntry = [lineup_ objectAtIndex: j];
            Lineup *lineup = [[Lineup alloc] init];
            lineup.artistId = [[NSNumber alloc] initWithInt:[[lineupEntry objectForKey:@"profile_id"] intValue]];
            lineup.artistName = [lineupEntry objectForKey:@"name"];
            lineup.hour = [format2 dateFromString:[lineupEntry objectForKey:@"hour"]];
            lineup.description = [lineupEntry objectForKey:@"description"];
            lineup.genre = [lineupEntry objectForKey:@"genre_main"];
            
            [concertLineup addObject:lineup];
        }
        concert.lineup = concertLineup;
        
        [clubEvents addObject:concert];
    }
    club.events = clubEvents;
    
    return club;
    
}

+ (NSArray *) parsePlaces:(NSDictionary *)data {
    
    NSMutableArray *_data = [NSMutableArray array];
    
    NSArray *entries = [data objectForKey:@"geonames"];
    
    for (int i = 0; i < [entries count]; i++) {
        NSDictionary *entry = [entries objectAtIndex:i];
        
        Place *place = [[Place alloc] init];
        place.placeId = [[NSNumber alloc] initWithInt:[[entry objectForKey:@"adminCode3"] intValue]];
        place.name = [entry objectForKey:@"name"];
        place.state = [entry objectForKey:@"adminName1"];
        place.country = [entry objectForKey:@"countryName"];
        place.latitude = [NSNumber numberWithDouble: [[entry objectForKey:@"lat"] doubleValue]];
        place.longitude = [NSNumber numberWithDouble: [[entry objectForKey:@"lng"] doubleValue]];

        [_data addObject:place];
    }
    return [_data copy];
    
}

@end
