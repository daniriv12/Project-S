//
//  Concert.h
//  stagend
//
//  Created by Giovanni Iembo on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Concert : NSObject

@property (strong, nonatomic) NSNumber *concertId;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *clubId;
@property (strong, nonatomic) NSString *place;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *zip;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSArray *lineup;

@end
