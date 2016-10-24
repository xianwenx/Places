//
//  ModifyRecordsFromManagedObjectsOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "ModifyRecordsFromManagedObjectsOperation.h"

@interface ModifyRecordsFromManagedObjectsOperation ()
@property (nonatomic, readwrite, strong) NSArray            *modifiedManagedObjectIDs;
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@property (nonatomic, readwrite, strong) CloudKitController *cloudKitController;
@end

@implementation ModifyRecordsFromManagedObjectsOperation

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                        cloudKitController:(CloudKitController *)cloudKitController {
    return [self initWithCoreDataController:coreDataController
                         cloudKitController:cloudKitController
                   modifiedManagedObjectIDs:nil
                           deletedRecordIDs:nil]; // TODO deviation from behavior
}

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                        cloudKitController:(CloudKitController *)cloudKitController
                  modifiedManagedObjectIDs:(NSArray *)modifiedManagedObjectIDs
                          deletedRecordIDs:(NSArray *)deletedRecordIDs {
    if ((self = [super init])) {
        _coreDataController = coreDataController;
        _cloudKitController = cloudKitController;
        _modifiedManagedObjectIDs = modifiedManagedObjectIDs;
        
        [self setRecordIDsToDelete:deletedRecordIDs];
        
    }
    return self;
}

- (void)main {
    [self setOperationBlocks];
    
    NSManagedObjectContext *backgroundQueueContext = [[self coreDataController] createBackgroundQueueContext];
    [backgroundQueueContext performBlockAndWait:^{
        NSArray *modifiedRecords = nil;
       
        NSArray *modifiedManagedObjectIDs = [self modifiedManagedObjectIDs];
        if (modifiedManagedObjectIDs != nil) {
            modifiedRecords = [self modifyFetchedRecordIDs:backgroundQueueContext
                                  modifiedManagedObjectIDs:modifiedManagedObjectIDs];
        } else if ([self preModifiedRecords] != nil) {
            modifiedRecords = [self preModifiedRecords];
        } else {
            modifiedRecords = [NSArray array];
        }
        
        if ([modifiedRecords count] > 0) {
            if ([self recordsToSave] == nil) {
                [self setRecordsToSave:modifiedRecords];
            } else {
                NSArray *appendedRecordsToSave = [[self recordsToSave] arrayByAddingObjectsFromArray:modifiedRecords];
                [self setRecordsToSave:appendedRecordsToSave];
            }
        }
        
        [super main];
    }];
}

- (NSArray *)modifyFetchedRecordIDs:(NSManagedObjectContext *)managedObjectContext
           modifiedManagedObjectIDs:(NSArray *)modifiedManagedObjectIDs {
    NSArray *result = nil;
    
    NSDictionary *fetchedRecords = [self fetchedRecordsToModify];
    if (fetchedRecords != nil) {
        NSMutableArray *modifiedRecords = [NSMutableArray array];
        
        NSArray *modifiedManagedObjects = [[self coreDataController] fetchCloudKitManagedObjects:managedObjectContext
                                                                                managedObjectIDs:modifiedManagedObjectIDs];
        
        for (CloudKitManagedObject *cloudKitObject in modifiedManagedObjects) {
            CKRecordID *recordID = [cloudKitObject cloudKitRecordID];
            if (recordID != nil) {
                CKRecord *record = fetchedRecords[recordID];
                CKRecord *recordToAppend = [cloudKitObject managedObjectToRecord:record];
                [modifiedRecords addObject:recordToAppend];
            }
        }
        
        result = [modifiedRecords copy];
    }
    
    return result;
    
}

- (void)setOperationBlocks {
    [self setPerRecordCompletionBlock:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (error != nil) {
            return; // TODO
        } else {
            NSLog(@"successful modification");
        }
        
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [self setModifyRecordsCompletionBlock:^(NSArray<CKRecord *> * _Nullable savedRecords,
                                            NSArray<CKRecordID *> * _Nullable deletedRecords,
                                            NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (error != nil) {
            return; // TODO
        } else if (deletedRecords != nil) {
            NSLog(@"deleted successful");
        }
        
        [[strongSelf cloudKitController] setLastCloudKitSyncTimeStamp:[NSDate date]];
    }];
}

@end
