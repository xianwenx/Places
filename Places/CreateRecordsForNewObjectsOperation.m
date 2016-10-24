//
//  CreateRecordsForNewObjectsOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "CreateRecordsForNewObjectsOperation.h"

@interface CreateRecordsForNewObjectsOperation ()
@property (nonatomic, readwrite, strong) NSArray            *createdRecords;
@property (nonatomic, readwrite, strong) NSArray            *insertedManagedObjectIDs;
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@end

@implementation CreateRecordsForNewObjectsOperation

- (instancetype)initWithInsertedManagedObjectIDs:(NSArray *)insertedManagedObjectIDs
                              coreDataController:(CoreDataController *)coreDataController {
    if ((self = [super init])) {
        _insertedManagedObjectIDs = insertedManagedObjectIDs;
        _coreDataController = coreDataController;
    }
    return self;
}

- (void)main {
    NSManagedObjectContext *backgroundObjectContext = [[self coreDataController] createBackgroundQueueContext];
    
    if ([[self insertedManagedObjectIDs] count] > 0) {
        [backgroundObjectContext performBlockAndWait:^{
            NSArray *insertedCloudKitObjects = [[self coreDataController] fetchCloudKitManagedObjects:backgroundObjectContext
                                                                                     managedObjectIDs:[self insertedManagedObjectIDs]];
            NSMutableArray *createdRecords = [NSMutableArray array];
            for (CloudKitManagedObject *cloudKitObject in insertedCloudKitObjects) {
                CKRecord *record = [cloudKitObject managedObjectToRecord:nil];
                [createdRecords addObject:record];
            }
            [self setCreatedRecords:[createdRecords copy]];
            
            [[self coreDataController] saveBackgroundQueueContext:backgroundObjectContext];
        }];
    }

}

@end
