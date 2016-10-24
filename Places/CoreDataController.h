//
//  CoreDataController.h
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CloudKitManagedObject.h"
#import "CloudKitController.h"

@interface CoreDataController : NSObject
@property (nonatomic, readonly, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, readwrite, strong) CloudKitController *cloudKitController;

- (void)saveContext;
- (NSManagedObjectContext *)createBackgroundQueueContext;
- (void)saveBackgroundQueueContext:(NSManagedObjectContext *)backgroundQueueContext;
- (NSArray<__kindof CloudKitManagedObject *> *)fetchCloudKitManagedObjects:(NSManagedObjectContext *)managedObjectContext
                                                          managedObjectIDs:(NSArray<__kindof NSManagedObjectID *>*)managedObjectIDs;
@end
