//
//  CoreDataController.m
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "CoreDataController.h"
#import <CloudKit/CloudKit.h>
#import "CloudKitManagedObject.h"
@interface CoreDataController ()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *backgroundQueueContext;

@end


@implementation CoreDataController
@synthesize persistentContainer = _persistentContainer;

- (instancetype)init {
    if ((self = [super init])) {
        _cloudKitController = [[CloudKitController alloc] initWithCoreDataController:self];
    }
    return self;
}

#pragma mark - Core Data Stack


- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Places"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    _backgroundQueueContext = [_persistentContainer newBackgroundContext];
                    [[_persistentContainer viewContext] setAutomaticallyMergesChangesFromParent:YES];
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (NSManagedObjectContext *)mainQueueContext {
    return [[self persistentContainer] viewContext];
}

- (NSSet<__kindof CKRecordID *> *) insertedManagedObjectIDs {
    NSSet<__kindof CKRecordID *>    *result     = nil;
    NSMutableSet                    *objectIDs  = [NSMutableSet set];
    
    for (NSManagedObject *managedObject in [[[self mainQueueContext] insertedObjects] copy]) {
        [objectIDs addObject:[managedObject objectID]];
    }
    result = [objectIDs copy];
    
    return result;
}

- (NSSet<__kindof CKRecordID *> *) modifiedManagedObjectIDs {
    NSSet<__kindof CKRecordID *>    *result     = nil;
    NSMutableSet                    *objectIDs  = [NSMutableSet set];
    
    for (NSManagedObject *managedObject in [[[self mainQueueContext] updatedObjects] copy]) {
        [objectIDs addObject:[managedObject objectID]];
    }
    result = [objectIDs copy];
    
    return result;
}

- (NSSet<__kindof CKRecordID *> *) deletedManagedObjectIDs {
    NSSet<__kindof CKRecordID *>    *result     = nil;
    NSMutableSet                    *objectIDs  = [NSMutableSet set];
    
    for (NSManagedObject *managedObject in [[[self mainQueueContext] deletedObjects] copy]) {
        [objectIDs addObject:[managedObject objectID]];
    }
    result = [objectIDs copy];
    
    return result;
}

- (void)savePrivateObjectContext {
    NSManagedObjectContext *backgroundQueueContext = [self backgroundQueueContext];
    [backgroundQueueContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL result = [backgroundQueueContext save:&error];
        if (result == NO) {
            //         @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@" userInfo:<#(nullable NSDictionary *)#>]
        }
    }];
}

- (void)saveBackgroundQueueContext:(NSManagedObjectContext *)backgroundQueueContext {
    if ([backgroundQueueContext hasChanges]) {
        NSError *error = nil;
        BOOL result = [backgroundQueueContext save:&error];
        if (result == NO) {
            //         @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@" userInfo:<#(nullable NSDictionary *)#>]
        }
    }
}

- (void)save {
    NSManagedObjectContext *mainQueueContext = [[self persistentContainer] viewContext];
    NSManagedObjectContext *backgroundQueueContext = [self backgroundQueueContext];
    
    NSSet *insertedObjects = [mainQueueContext insertedObjects];
    NSSet *updatedObjects = [mainQueueContext updatedObjects];
    
    
    if ([backgroundQueueContext hasChanges] || [mainQueueContext hasChanges]) {
        [mainQueueContext performBlockAndWait:^{
            NSError *error = nil;
            BOOL result = [mainQueueContext save:&error];
            if (result == NO) {
       //         @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@" userInfo:<#(nullable NSDictionary *)#>]
            }
            
            [self savePrivateObjectContext];
        /** TODO
            [[self cloudKitController] saveChangesToCloudKit:insertedManagedObjectIDs modifiedManagedObjectIDs:modifiedManagedObjectIDs deletedRecordIDs:deletedRecordIDs)];
            **/
        }];
    }
}

- (NSArray<__kindof CloudKitManagedObject *> *)fetchCloudKitManagedObjects:(NSManagedObjectContext *)managedObjectContext
                                                          managedObjectIDs:(NSArray<__kindof NSManagedObjectID *>*)managedObjectIDs {
    
    NSArray<__kindof CloudKitManagedObject *>           *result                 =   nil;
    NSMutableArray<__kindof CloudKitManagedObject *>    *cloudKitManagedObjects =   nil;
    
    for (NSManagedObjectID *managedObjectID in managedObjectIDs) {
        NSError *error = nil;
        NSManagedObject *managedObject = [managedObjectContext existingObjectWithID:managedObjectID error:&error];
        if (managedObject == nil) {
            //         @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@" userInfo:<#(nullable NSDictionary *)#>]

        }
        if ([managedObject isKindOfClass:[CloudKitManagedObject class]]) {
            [cloudKitManagedObjects addObject:((CloudKitManagedObject *) managedObject)];
            
        }
    }
    
    result = [cloudKitManagedObjects copy];
    return result;
    
}

- (NSManagedObjectContext *)createBackgroundQueueContext {
    NSManagedObjectContext *backgroundContext = [[self persistentContainer] newBackgroundContext];
    [backgroundContext setAutomaticallyMergesChangesFromParent:YES];
    return backgroundContext;
}

@end
