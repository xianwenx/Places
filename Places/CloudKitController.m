//
//  CloudKitController.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "CloudKitController.h"
#import "ProcessSyncChangesOperation.h"
#import "SaveChangedRecordsToCoreDataOperation.h"
#import "ClearDeletedCloudKitObjectsOperation.h"
#import "CreateRecordsForNewObjectsOperation.h"
#import "FetchOfflineChangesFromCoreDataOperation.h"
#import "FetchAllSubscriptionsOperation.h"
#import "ProcessServerSubscriptionsOperation.h"
#import "FetchRecordsForModifiedObjectsOperation.h"
#import "ModifyRecordsFromManagedObjectsOperation.h"
#import "FetchRecordChangesForCloudKitZoneOperation.h"
#import "FetchAllRecordZonesOperation.h"
#import "ProcessServerRecordZonesOperation.h"

@interface CloudKitController ()
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@property (nonatomic, readwrite, strong) NSOperationQueue   *operationQueue;
@property (nonatomic, readwrite, strong) CKDatabase         *privateDatabase;
@end

@implementation CloudKitController

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController {
    NSLog(@"HEY");
    if ((self = [super init])) {
        _coreDataController =   coreDataController;
        _operationQueue     =   [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:1];
        
        _privateDatabase    =   [[CKContainer defaultContainer] privateCloudDatabase];
        
        [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus,
                                                                             NSError * _Nullable error) {
            if (accountStatus == CKAccountStatusAvailable) {
                [self initializeCloudKit];
            } else {
                [self handleCloudKitUnavailable:accountStatus error:error];
            }
        }];
    }
    return self;
}

- (void)initializeCloudKit {
    [[self operationQueue] setSuspended:YES];
    
    CKModifyRecordZonesOperation *modifyRecordZonesOperation = [self queueZoneInitializationOperations];
    
    NSBlockOperation *syncAllZonesOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self queueFullSyncOperations];
    }];
    
    [syncAllZonesOperation addDependency:modifyRecordZonesOperation];
    [[self operationQueue] addOperation:syncAllZonesOperation];
    [[self operationQueue] setSuspended:NO];
    
}

#pragma mark - Modify Zones

- (CKModifyRecordZonesOperation *)queueZoneInitializationOperations {
    FetchAllRecordZonesOperation *fetchAllRecordZonesOperation = [FetchAllRecordZonesOperation fetchAllRecordZonesOperation];
    ProcessServerRecordZonesOperation *processServerRecordZonesOperation = [[ProcessServerRecordZonesOperation alloc] init];
    CKModifyRecordZonesOperation *modifyRecordZonesOperation = [self createModifyRecordZonesOperation:nil recordZonesToDelete:nil];
    
    NSBlockOperation *transferFetchedZonesOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSDictionary *fetchedRecordZones = [fetchAllRecordZonesOperation fetchedRecordZones];
        if (fetchedRecordZones != nil) {
            [processServerRecordZonesOperation setPreProcessRecordZoneIDs:[[fetchedRecordZones allKeys] mutableCopy]];
        }
    }];
    
    NSBlockOperation *transferProcessedZonesOperation = [NSBlockOperation blockOperationWithBlock:^{
        modifyRecordZonesOperation.recordZonesToSave = processServerRecordZonesOperation.postProcessRecordZonesToCreate;
        modifyRecordZonesOperation.recordZoneIDsToDelete = processServerRecordZonesOperation.postProcessRecordZoneIDsToDelete;
    }];
    
    [transferFetchedZonesOperation addDependency:fetchAllRecordZonesOperation];
    [processServerRecordZonesOperation addDependency:transferFetchedZonesOperation];
    [transferProcessedZonesOperation addDependency:processServerRecordZonesOperation];
    [modifyRecordZonesOperation addDependency:transferProcessedZonesOperation];
    
    NSOperationQueue *operationQueue = [self operationQueue];
    [operationQueue addOperation:fetchAllRecordZonesOperation];
    [operationQueue addOperation:transferFetchedZonesOperation];
    [operationQueue addOperation:processServerRecordZonesOperation];
    [operationQueue addOperation:transferProcessedZonesOperation];
    [operationQueue addOperation:modifyRecordZonesOperation];
    
    return modifyRecordZonesOperation;
}

- (CKModifyRecordZonesOperation *)createModifyRecordZonesOperation:(NSArray *)recordZonesToSave recordZonesToDelete:(NSArray *)recordZonesToDelete {
    CKModifyRecordZonesOperation *modifyRecordZonesOperation = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:recordZonesToSave recordZoneIDsToDelete:recordZonesToDelete];
    [modifyRecordZonesOperation setModifyRecordZonesCompletionBlock:^(NSArray<CKRecordZone *> * records, NSArray<CKRecordZoneID *> * records2, NSError * error) {
        NSLog(@"AYY");
    }];
    return modifyRecordZonesOperation;
}

- (void)handleCloudKitUnavailable:(CKAccountStatus)accountStatus error:(NSError *)error {

    
}

- (void)saveChangesToCloudKit:(NSArray *)insertedObjectIDs
            modifiedObjectIDs:(NSArray *)modifiedObjectIDs
             deletedRecordIDs:(NSArray *)deletedRecordIDs {
    
    CreateRecordsForNewObjectsOperation *createRecordsForNewObjectsOperation = [[CreateRecordsForNewObjectsOperation alloc] initWithInsertedManagedObjectIDs:insertedObjectIDs
                                                                                                                  coreDataController:[self coreDataController]];
    
    FetchRecordsForModifiedObjectsOperation *fetchModifiedRecordsOperation = [[FetchRecordsForModifiedObjectsOperation alloc] initWithCoreDataController:[self coreDataController] modifiedManagedObjectIDs:modifiedObjectIDs]; // XXX
    
    ModifyRecordsFromManagedObjectsOperation *modifyRecordsOperation = [[ModifyRecordsFromManagedObjectsOperation alloc] initWithCoreDataController:[self coreDataController]
                                                                                                    cloudKitController:self
                                                                                              modifiedManagedObjectIDs:modifiedObjectIDs
                                                                                                      deletedRecordIDs:deletedRecordIDs];
    
    ClearDeletedCloudKitObjectsOperation *clearDeletedCloudKitObjectsOperation = [[ClearDeletedCloudKitObjectsOperation alloc] initWithCoreDataController:[self coreDataController]];
    
    NSBlockOperation *transferCreatedRecordsOperation = [NSBlockOperation blockOperationWithBlock:^{
        [modifyRecordsOperation setRecordsToSave:[createRecordsForNewObjectsOperation createdRecords]];
    }];
    
    NSBlockOperation *transferFetchedRecordsOperation = [NSBlockOperation blockOperationWithBlock:^{
        [modifyRecordsOperation setFetchedRecordsToModify:[fetchModifiedRecordsOperation fetchedRecords]];
    }];
    
    [transferCreatedRecordsOperation addDependency:createRecordsForNewObjectsOperation];
    [transferFetchedRecordsOperation addDependency:fetchModifiedRecordsOperation];
    [modifyRecordsOperation addDependency:transferCreatedRecordsOperation];
    [modifyRecordsOperation addDependency:transferFetchedRecordsOperation];
    [clearDeletedCloudKitObjectsOperation addDependency:modifyRecordsOperation];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperation:createRecordsForNewObjectsOperation];
    [operationQueue addOperation:transferCreatedRecordsOperation];
    [operationQueue addOperation:fetchModifiedRecordsOperation];
    [operationQueue addOperation:transferFetchedRecordsOperation];
    [operationQueue addOperation:modifyRecordsOperation];
    [operationQueue addOperation:clearDeletedCloudKitObjectsOperation];
    
}

- (void)performFullSync {
    [self queueFullSyncOperations];
}




- (void)queueFullSyncOperations {
    
    // 1. Fetch all the changes both locally and from each zone

    NSArray *entityNames = [[CloudKitZone allCloudKitZoneNames] allObjects]; // TODO
    
    FetchOfflineChangesFromCoreDataOperation    *fetchOfflineChangesFromCoreDataOperation   =
    [[FetchOfflineChangesFromCoreDataOperation alloc] initWithCoreDataController:[self coreDataController]
                                                              cloudKitController:self
                                                                     entityNames:entityNames];
    
    FetchRecordChangesForCloudKitZoneOperation  *fetchPlaceZoneChangesOperation             =
    [[FetchRecordChangesForCloudKitZoneOperation alloc] initWithCloudKitZone:[CloudKitZone placeZone]];
    
    // 2. Process the changes after transfering

    ProcessSyncChangesOperation                 *processSyncChangesOperation                =
    [[ProcessSyncChangesOperation alloc] initWithCoreDataController:[self coreDataController]];
    
    NSBlockOperation *transferDataToProcessSyncChangesOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[processSyncChangesOperation preProcessLocalChangedObjectIDs]  addObjectsFromArray:[fetchOfflineChangesFromCoreDataOperation updatedManagedObjectIDs]];
        [[processSyncChangesOperation preProcessLocalDeletedRecordIDs]  addObjectsFromArray:[fetchOfflineChangesFromCoreDataOperation deletedRecordIDs]];
        
        [[processSyncChangesOperation preProcessServerChangedRecords]   addObjectsFromArray:[fetchPlaceZoneChangesOperation changedRecords]];
        [[processSyncChangesOperation preProcessServerDeletedRecordIDs] addObjectsFromArray:[fetchPlaceZoneChangesOperation deletedRecordIDs]];
    }];
    
    // 3. Fetch records from the server that we need to change

    FetchRecordsForModifiedObjectsOperation     *fetchRecordsForModifiedObjectsOperation    =
    [[FetchRecordsForModifiedObjectsOperation alloc] initWithCoreDataController:[self coreDataController]];
    
    NSBlockOperation *transferDataToFetchRecordsOperation           = [NSBlockOperation blockOperationWithBlock:^{
        [fetchRecordsForModifiedObjectsOperation setPreFetchModifiedRecords:[processSyncChangesOperation postProcessChangesToServer]];
    }];
    
    // 4. Modify records in the cloud

    ModifyRecordsFromManagedObjectsOperation *modifyRecordsFromManagedObjectsOperation      =
    [[ModifyRecordsFromManagedObjectsOperation alloc] initWithCoreDataController:[self coreDataController]
                                                              cloudKitController:self];
    
    NSBlockOperation *transferDataToModifyRecordsOperation          = [NSBlockOperation blockOperationWithBlock:^{
        NSDictionary *fetchedRecords = [fetchRecordsForModifiedObjectsOperation fetchedRecords];
        if (fetchedRecords != nil) {
            [modifyRecordsFromManagedObjectsOperation setFetchedRecordsToModify:fetchedRecords];
        }
        [modifyRecordsFromManagedObjectsOperation setPreModifiedRecords:[processSyncChangesOperation postProcessChangesToServer]];
        [modifyRecordsFromManagedObjectsOperation setRecordIDsToDelete:[processSyncChangesOperation postProcessDeletesToServer]];
    }];
    
    // 5. Modify records locally

    SaveChangedRecordsToCoreDataOperation *saveChangedRecordsToCoreDataOperation            =
    [[SaveChangedRecordsToCoreDataOperation alloc] initWithCoreDataController:[self coreDataController]];
    
    NSBlockOperation *transferDataToSaveChangesToCoreDataOperation  = [NSBlockOperation blockOperationWithBlock:^{
        [saveChangedRecordsToCoreDataOperation setChangedRecords:[processSyncChangesOperation postProcessChangesToCoreData]];
        [saveChangedRecordsToCoreDataOperation setDeletedRecordIDs:[processSyncChangesOperation postProcessDeletesToCoreData]];
    }];
    
    // 6. Delete all of the DeletedCloudKitObjects
    ClearDeletedCloudKitObjectsOperation *clearDeletedCloudKitObjectsOperation = [[ClearDeletedCloudKitObjectsOperation alloc] initWithCoreDataController:[self coreDataController]];
    
      // set dependencies
    
    [transferDataToProcessSyncChangesOperation addDependency:fetchOfflineChangesFromCoreDataOperation];
    [transferDataToProcessSyncChangesOperation addDependency:fetchPlaceZoneChangesOperation];
    
    [processSyncChangesOperation addDependency:transferDataToProcessSyncChangesOperation];
    [transferDataToFetchRecordsOperation addDependency:processSyncChangesOperation];
    [fetchRecordsForModifiedObjectsOperation addDependency:transferDataToFetchRecordsOperation];
    
    [transferDataToSaveChangesToCoreDataOperation addDependency:processSyncChangesOperation];
    [saveChangedRecordsToCoreDataOperation addDependency:transferDataToModifyRecordsOperation];
    
    [clearDeletedCloudKitObjectsOperation addDependency:saveChangedRecordsToCoreDataOperation];
    
    NSOperationQueue *operationQueue = [self operationQueue];
    [operationQueue addOperation:fetchOfflineChangesFromCoreDataOperation];
    [operationQueue addOperation:fetchPlaceZoneChangesOperation];
    [operationQueue addOperation:transferDataToProcessSyncChangesOperation];
    [operationQueue addOperation:processSyncChangesOperation];
    [operationQueue addOperation:transferDataToFetchRecordsOperation];
    [operationQueue addOperation:fetchRecordsForModifiedObjectsOperation];
    [operationQueue addOperation:transferDataToModifyRecordsOperation];
    [operationQueue addOperation:modifyRecordsFromManagedObjectsOperation];
    [operationQueue addOperation:transferDataToSaveChangesToCoreDataOperation];
    [operationQueue addOperation:saveChangedRecordsToCoreDataOperation];
    [operationQueue addOperation:clearDeletedCloudKitObjectsOperation];
    
}

- (CKModifySubscriptionsOperation *)queueSubscriptionInitializationOperations {
    FetchAllSubscriptionsOperation *fetchAllSubscriptionsOperation = [FetchAllSubscriptionsOperation fetchAllSubscriptionsOperation];
    /**
    ProcessServerSubscriptionsOperation *processServerSubscriptionsOperation = [[ProcessServerSubscriptionsOperation alloc] init];
    ModifyRecordsFromManagedObjectsOperation *modifyRecordsFromManagedObjectsOperation = [self createModifySubscriptionsOperation];
    **/
    
    return nil;
    
}

- (SaveChangedRecordsToCoreDataOperation *)queueChangeOperationsForZone:(CloudKitZone *)cloudKitZone
                                             modifyRecordZonesOperation:(CKModifyRecordZonesOperation *)modifyRecordZonesOperation {
    FetchRecordChangesForCloudKitZoneOperation *fetchRecordChangesOperation = [[FetchRecordChangesForCloudKitZoneOperation alloc] initWithCloudKitZone:cloudKitZone];
    
    SaveChangedRecordsToCoreDataOperation *saveChangedRecordsToCoreDataOperation = [[SaveChangedRecordsToCoreDataOperation alloc] initWithCoreDataController:[self coreDataController]];
    
    NSBlockOperation *dataTransferOperation = [NSBlockOperation blockOperationWithBlock:^{
        [saveChangedRecordsToCoreDataOperation setChangedRecords:[fetchRecordChangesOperation changedRecords]];
        [saveChangedRecordsToCoreDataOperation setDeletedRecordIDs:[fetchRecordChangesOperation deletedRecordIDs]];
    }];
    
    if (modifyRecordZonesOperation != nil) {
        [fetchRecordChangesOperation addDependency:modifyRecordZonesOperation];
    }
    
    [dataTransferOperation addDependency:fetchRecordChangesOperation];
    [saveChangedRecordsToCoreDataOperation addDependency:dataTransferOperation];
    
    [[self operationQueue] addOperation:fetchRecordChangesOperation];
    [[self operationQueue] addOperation:dataTransferOperation];
    [[self operationQueue] addOperation:saveChangedRecordsToCoreDataOperation];
    
    return saveChangedRecordsToCoreDataOperation;
    
}

- (NSDate *)lastCloudKitSyncTimeStamp {
    NSDate      *result     =   nil;
    
    id syncTimeStampValue   =   [[NSUserDefaults standardUserDefaults] objectForKey:@"LastCloudKitSyncTimestamp"];
    
    if ([syncTimeStampValue isKindOfClass:[NSDate class]]) {
        result              =   syncTimeStampValue;
    } else {
        result              =   [NSDate distantPast];
    }
    return result;
}

- (void)setLastCloudKitSyncTimeStamp:(NSDate *)lastCloudKitSyncTimeStamp {
    [[NSUserDefaults standardUserDefaults] setObject:lastCloudKitSyncTimeStamp forKey:@"LastCloudKitSyncTimestamp"];
}


@end
