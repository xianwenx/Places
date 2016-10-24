//
//  FetchOfflineChangesFromCoreDataOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "FetchOfflineChangesFromCoreDataOperation.h"
#import "DeletedCloudKitObject+CoreDataClass.h"

@interface FetchOfflineChangesFromCoreDataOperation ()
@property (nonatomic, readwrite, strong) NSMutableArray     *updatedManagedObjectIDsMutable;
@property (nonatomic, readwrite, strong) NSArray            *deletedRecordIDs;
@property (nonatomic, readwrite, strong) NSArray            *entityNames;
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@property (nonatomic, readwrite, strong) CloudKitController *cloudKitController;
@end

@implementation FetchOfflineChangesFromCoreDataOperation

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                        cloudKitController:(CloudKitController *)cloudKitController
                               entityNames:(NSArray *)entityNames {
    if ((self = [super init])) {
        _coreDataController         = coreDataController;
        _cloudKitController         = cloudKitController;
        _entityNames                = entityNames;
        
        // TODO init arrays
        _updatedManagedObjectIDs    =  [NSMutableArray array];
        _deletedRecordIDs           =  [NSArray array];
    }
    return self;
}

- (void)main {
    NSManagedObjectContext *backgroundQueueContext = [[self coreDataController] createBackgroundQueueContext];
    [backgroundQueueContext performBlockAndWait:^{
        NSDate *lastCloudKitSyncTimeStamp = [[self cloudKitController] lastCloudKitSyncTimeStamp];
        
        for (NSString *entityName in [self entityNames]) {
            [self fetchOfflineChangesForEntityName:entityName
                         lastCloudKitSyncTimeStamp:lastCloudKitSyncTimeStamp
                              managedObjectContext:backgroundQueueContext];
        }
        
        [self setDeletedRecordIDs:[self fetchDeletedRecordIDs:backgroundQueueContext]];
    }];
}

- (void)fetchOfflineChangesForEntityName:(NSString *)entityName
               lastCloudKitSyncTimeStamp:(NSDate *)lastCloudKitSyncTimeStamp
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"lastUpdate > %@", lastCloudKitSyncTimeStamp]];
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchResults == nil) {
        // TODO
    }
    
    for (NSManagedObject *managedObject in fetchResults) {
        NSManagedObjectID *objectID = [managedObject objectID];
        [[self updatedManagedObjectIDs] addObject:objectID];
    }
    
}

- (NSArray *)fetchDeletedRecordIDs:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DeletedCloudKitObject"]; // TODO
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchResults == nil) {
        // TODO
        return [NSArray array];
    }
    
    NSMutableArray *deletedRecordIDs = [NSMutableArray array];
    for (NSManagedObject *managedObject in fetchResults) {
        if ([managedObject isKindOfClass:[DeletedCloudKitObject class]]) {
            CKRecordID *cloudKitRecordID = [((DeletedCloudKitObject *) managedObject) cloudKitRecordID];
            [deletedRecordIDs addObject:cloudKitRecordID];
        }
    }
    return [deletedRecordIDs copy];


}

@end
