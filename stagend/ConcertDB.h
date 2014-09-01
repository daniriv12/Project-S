//
//  ConcertDB.h
//  stagend
//
//  Created by Giovanni Iembo on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ConcertDB : NSManagedObject

@property (nonatomic, retain) NSNumber * concertId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * city;

@end
