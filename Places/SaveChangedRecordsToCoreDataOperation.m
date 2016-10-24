//
//  SaveChangedRecordsToCoreDataOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "SaveChangedRecordsToCoreDataOperation.h"

@interface SaveChangedRecordsToCoreDataOperation ()
@property (nonatomic, readwrite, strong) NSMutableArray     *rootRecords;
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@end

@implementation SaveChangedRecordsToCoreDataOperation

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController {
    if ((self = [super init])) {
        _coreDataController = coreDataController;
        
        _changedRecords = [NSMutableArray array];
        _deletedRecordIDs = [NSMutableArray array];
        _rootRecords = [NSMutableArray array];
    }
    return self;
}

- (void)saveRecordToCoreData:(CKRecord *)record
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest          *fetchRequest           = nil;
    CloudKitManagedObject   *cloudKitManagedObject  = nil;

    fetchRequest            = [self newFetchRequestWithEntityName:[record recordType] recordName:[[record recordID] recordName]];
    cloudKitManagedObject   = [self fetchObjectForRequest:fetchRequest managedObjectContext:managedObjectContext];
    
    if (cloudKitManagedObject == nil) {
        cloudKitManagedObject  = [self newCloudKitManagedObjectWithEntityName:[record recordType] managedObjectContext:managedObjectContext];
    }
    
    [cloudKitManagedObject updateWithRecord:record];

}

- (CloudKitManagedObject *)newCloudKitManagedObjectWithEntityName:(NSString *)entityName
                                             managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    CloudKitManagedObject   *result             = nil;
    
    NSManagedObject *createdInstance = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                     inManagedObjectContext:managedObjectContext];
    
    if ([createdInstance isKindOfClass:[CloudKitManagedObject class]]) {
        result = (CloudKitManagedObject *) createdInstance;
    } else {
        // TODO
    }
    
    return result;
}

- (void)deleteRecordFromCoreDataWithRecordID:(CKRecordID *)recordID
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    CloudKitManagedObject   *objectToDelete         = nil;
    NSString                *entityName             = [recordID recordName];
    NSFetchRequest          *fetchRequest           = [self newFetchRequestWithEntityName:entityName
                                                               recordName:[recordID recordName]];
    
    objectToDelete = [self fetchObjectForRequest:fetchRequest managedObjectContext:managedObjectContext];
    if (objectToDelete != nil) {
        [managedObjectContext deleteObject:objectToDelete];
    }
    
}

- (NSFetchRequest *)newFetchRequestWithEntityName:(NSString *)entityName
                                    recordName:(NSString *)recordName {
    NSFetchRequest  *result                 = nil;
    
    NSPredicate     *recordNamePredicate    = [NSPredicate predicateWithFormat:@"recordName LIKE[c] %@", recordName];
    result                                  = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [result setPredicate:recordNamePredicate];
    
    return result;
}

- (NSString *)entityNameFromRecordName:(NSString *)recordName {
    NSString *result = nil;
    
    if ([recordName containsString:@"."] == NO) {
        // TODO
    }
    
    result = [[recordName componentsSeparatedByString:@"."] firstObject];
    
    return result;
}

- (CloudKitManagedObject *)fetchObjectForRequest:(NSFetchRequest *)request
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    CloudKitManagedObject   *result             = nil;
    
    NSError                 *error              = nil;
    NSArray                 *fetchRequestResult = nil;
    fetchRequestResult                          = [managedObjectContext executeFetchRequest:request
                                                                                      error:&error];
    
    if (fetchRequestResult == nil) {
         // TODO
    }
    
    if ([fetchRequestResult count] > 1) {
        // TODO
    }
    
    if ([fetchRequestResult count] == 1) {
        result = ((CloudKitManagedObject *) [fetchRequestResult firstObject]);
    }
    
    return result;
    
    
}

- (void)main {
    NSManagedObjectContext *backgroundQueueContext = [[self coreDataController] createBackgroundQueueContext];
    [backgroundQueueContext performBlockAndWait:^{
        for (CKRecord *record in [self changedRecords]) {
            if ([[record recordType] isEqualToString:@"Place"]) { // TODO
                [[self rootRecords] addObject:record];
            }
        }
        
        for (CKRecord *record in [self rootRecords]) {
            [self saveRecordToCoreData:record managedObjectContext:backgroundQueueContext];
        }
        
        for (CKRecordID *recordID in [self deletedRecordIDs]) {
            [self deleteRecordFromCoreDataWithRecordID:recordID managedObjectContext:backgroundQueueContext];
        }
        
        [[self coreDataController] saveBackgroundQueueContext:backgroundQueueContext];
    }];
}
@end
