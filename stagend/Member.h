//
//  Member.h
//  stagend
//
//  Created by Giovanni Iembo on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Member : NSObject

@property (strong, nonatomic) NSNumber *memberId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *instrument;

@end
