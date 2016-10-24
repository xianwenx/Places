//
//  ProcessSyncChangesOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "ProcessSyncChangesOperation.h"

@interface ProcessSyncChangesOperation ()
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@property (nonatomic, readwrite, strong) NSMutableArray     *changedCloudKitManagedObjects;
@end

@implementation ProcessSyncChangesOperation

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController {
    if ((self = [super init])) {
        _coreDataController = coreDataController;
        
        _preProcessLocalChangedObjectIDs    = [NSMutableArray array];
        _preProcessLocalDeletedRecordIDs    = [NSMutableArray array];
        _preProcessServerChangedRecords     = [NSMutableArray array];
        _preProcessServerDeletedRecordIDs   = [NSMutableArray array];
        
        _postProcessChangesToCoreData       = [NSMutableArray array];
        _postProcessChangesToServer         = [NSMutableArray array];
        _postProcessDeletesToCoreData       = [NSMutableArray array];
        _postProcessDeletesToServer         = [NSMutableArray array];
        
        _changedCloudKitManagedObjects      = [NSMutableArray array];
    }
    return self;
}

- (void)main {
    NSManagedObjectContext *backgroundQueueContext = [[self coreDataController] createBackgroundQueueContext];
    [backgroundQueueContext performBlockAndWait:^{
        NSArray *changedCloudKitManagedObjects = [[self coreDataController] fetchCloudKitManagedObjects:backgroundQueueContext
                                                                                       managedObjectIDs:[self preProcessLocalChangedObjectIDs]];
        [self setChangedCloudKitManagedObjects:[changedCloudKitManagedObjects mutableCopy]];
        
        [self processServerDeletions:backgroundQueueContext];
        [self processLocalDeletions];
        
        [self processConflicts:backgroundQueueContext];
        
        NSMutableArray *changedCloudKitManagedObjectsToRecords = [NSMutableArray array];
        for (CloudKitManagedObject *cloudKitObject in [self changedCloudKitManagedObjects]) {
            [changedCloudKitManagedObjectsToRecords addObject:[cloudKitObject managedObjectToRecord:nil]];
        }
        [[self postProcessChangesToServer] addObjectsFromArray:changedCloudKitManagedObjectsToRecords];
        
        
        [[self postProcessChangesToCoreData] addObjectsFromArray:[self preProcessServerChangedRecords]];
        [[self coreDataController] saveBackgroundQueueContext:backgroundQueueContext];
        
    }];
}

- (void)processServerDeletions:(NSManagedObjectContext *)managedObjectContext {
    for (CKRecord *deletedServerRecordID in [self preProcessServerDeletedRecordIDs]) {
        NSUInteger index = [[self changedCloudKitManagedObjects] indexOfObjectPassingTest:^BOOL(CloudKitManagedObject *obj,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
            return [[obj recordName] isEqualToString:[[deletedServerRecordID recordID] recordName]];
        }];
        
        if (index != NSNotFound) {
            [[self changedCloudKitManagedObjects] removeObjectAtIndex:index];
        }
        
        [[self postProcessDeletesToCoreData] addObject:deletedServerRecordID];
    }
}

- (void)processLocalDeletions {
    for (CKRecordID *deletedLocalRecordID in [self preProcessLocalDeletedRecordIDs]) {
        NSUInteger index = [[self preProcessLocalDeletedRecordIDs] indexOfObjectPassingTest:^BOOL(CKRecordID *obj,
                                                                                                NSUInteger idx,
                                                                                                BOOL * _Nonnull stop) {
            return [[obj recordName] isEqualToString:[deletedLocalRecordID recordName]];
        }];
        
        if (index != NSNotFound) {
            [[self preProcessServerChangedRecords] removeObjectAtIndex:index];
        }

        
        [[self postProcessDeletesToServer] addObject:deletedLocalRecordID];
    }
}

- (void)processConflicts:(NSManagedObjectContext *)managedObjectContext {
    NSMutableArray *changedLocalRecordNamesArray = [NSMutableArray array];
    for (CloudKitManagedObject *cloudKitObject in [self changedCloudKitManagedObjects]) {
        [changedLocalRecordNamesArray addObject:[cloudKitObject recordName]];
    }
    
    NSMutableArray *changedServerRecordNamesArray = [NSMutableArray array];
    for (CKRecord *record in [self preProcessServerChangedRecords]) {
        [changedServerRecordNamesArray addObject:[[record recordID] recordName]];
    }
    
    NSSet *changedLocalRecordNamesSet = [NSSet setWithArray:changedLocalRecordNamesArray]; // TODO  copy..
    NSSet *changedServerRecordNamesSet = [NSSet setWithArray:changedServerRecordNamesArray]; // TODO  copy..

    NSMutableSet *conflictRecordNameSet = [changedLocalRecordNamesSet mutableCopy];
    [conflictRecordNameSet intersectSet:changedServerRecordNamesSet];
    
    for (NSString *recordName in conflictRecordNameSet) {
        [self resolveConflict:recordName managedObjectContext:managedObjectContext];
    }
    
}

- (void)resolveConflict:(NSString *)recordName managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSUInteger serverChangedRecordIndex = [[self preProcessServerChangedRecords] indexOfObjectPassingTest:^BOOL(CKRecord *obj,
                                                                                              NSUInteger idx,
                                                                                              BOOL * _Nonnull stop) {
        return [[[obj recordID] recordName] isEqualToString:recordName];
    }];
    
    if (serverChangedRecordIndex == NSNotFound) {
        // TODO exception
        return;
    }
    
    NSUInteger localChangedObjectIndex = [[self changedCloudKitManagedObjects] indexOfObjectPassingTest:^BOOL(CloudKitManagedObject *obj,
                                                                                                              NSUInteger idx,
                                                                                                              BOOL * _Nonnull stop) {
        return [[obj recordName] isEqualToString:recordName];
    }];
    
    CKRecord *serverChangedRecord = [self preProcessServerChangedRecords][serverChangedRecordIndex];
    CloudKitManagedObject *localChangedObject = [self changedCloudKitManagedObjects][localChangedObjectIndex];
    
    NSDate *serverChangedRecordLastUpdate = serverChangedRecord[@"lastUpdate"];
    NSDate *localChangedObjectLastUpdate = [localChangedObject lastUpdate];
    
    if (serverChangedRecordLastUpdate == nil || localChangedObjectLastUpdate == nil) {
        // TODO exception
        return;
    }
    
    [[self preProcessServerChangedRecords] removeObjectAtIndex:serverChangedRecordIndex];
    [[self changedCloudKitManagedObjects] removeObjectAtIndex:localChangedObjectIndex];
    
    if ([serverChangedRecordLastUpdate compare:localChangedObjectLastUpdate] == NSOrderedDescending) {
        [[self postProcessChangesToCoreData] addObject:serverChangedRecord];
    } else if ([serverChangedRecordLastUpdate compare:localChangedObjectLastUpdate] == NSOrderedAscending) {
        [[self postProcessChangesToCoreData] addObject:[localChangedObject managedObjectToRecord:serverChangedRecord]];
    } else {
        // nothing
    }
}
@end
