//
//  Artist.h
//  stagend
//
//  Created by Giovanni Iembo on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Artist : NSObject

@property (strong, nonatomic) NSNumber *artistId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *mainGenre;
@property (strong, nonatomic) NSString *genres;
@property (strong, nonatomic) NSString *biography;
@property (strong, nonatomic) NSArray *members;
@property (strong, nonatomic) NSArray *events;
//daniel rivera
@property (strong, nonatomic) NSString *url;

@end
