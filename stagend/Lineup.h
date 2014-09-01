//
//  Lineup.h
//  stagend
//
//  Created by Giovanni Iembo on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lineup : NSObject
@property (strong, nonatomic) NSNumber *artistId;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSDate *hour;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *genre;

@end
