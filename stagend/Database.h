//
//  Database.h
//  stagend
//
//  Created by  on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ArtistDB.h"

@interface Database : NSObject 

@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) NSString *dbName;

- (id)initWithDBName:(NSString *)name;
- (void)saveContext;
- (void)removeEntitiesWithEntity:(NSString *)entity;

@end