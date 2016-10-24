//
//  FetchRecordsForModifiedObjectsOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "FetchRecordsForModifiedObjectsOperation.h"
@interface FetchRecordsForModifiedObjectsOperation ()
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@property (nonatomic, readwrite, strong) NSArray *modifiedManagedObjectIDs;

@end

@implementation FetchRecordsForModifiedObjectsOperation


- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                  modifiedManagedObjectIDs:(NSArray *)modifiedManagedObjectIDs {
    if ((self = [super init])) {
        _coreDataController         = coreDataController;
        _modifiedManagedObjectIDs   = modifiedManagedObjectIDs;
    }
    return self;
}

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController {
    return [self initWithCoreDataController:coreDataController modifiedManagedObjectIDs:nil];
}

- (void)main {
    [self setOperationBlocks];
    NSManagedObjectContext *backgroundQueueContext = [[self coreDataController] createBackgroundQueueContext];
    [backgroundQueueContext performBlockAndWait:^{
        NSArray *modifiedManagedObjectIDs   = [self modifiedManagedObjectIDs];
        NSArray *preFetchModifiedRecords    = [self preFetchModifiedRecords];

        if (modifiedManagedObjectIDs != nil) {
           NSArray *modifiedCloudKitObjects =  [[self coreDataController] fetchCloudKitManagedObjects:backgroundQueueContext
                                                                                     managedObjectIDs:modifiedManagedObjectIDs];
            
            NSMutableArray *recordIDs = [NSMutableArray array];
            for (CloudKitManagedObject *cloudKitObject in modifiedCloudKitObjects) {
                [recordIDs addObject:[cloudKitObject cloudKitRecordID]];
            }
            [self setRecordIDs:[recordIDs copy]];
            
        } else if (preFetchModifiedRecords != nil) {
            
            NSMutableArray *recordIDs = [NSMutableArray array];
            for (CKRecord *cloudKitRecord in preFetchModifiedRecords) {
                [recordIDs addObject:[cloudKitRecord recordID]];
            }
            [self setRecordIDs:[recordIDs copy]];
        }
        
        [super main];
    }];
}

- (void)setOperationBlocks {
    __weak typeof(self) weakSelf = self;
    [self setFetchRecordsCompletionBlock:^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable fetchedRecords, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf setFetchedRecords:fetchedRecords];
    }];
}

@end
