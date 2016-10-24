//
//  ClearDeletedCloudKitObjectsOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "ClearDeletedCloudKitObjectsOperation.h"

@interface ClearDeletedCloudKitObjectsOperation ()
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@end

@implementation ClearDeletedCloudKitObjectsOperation

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController {
    if ((self = [super init])) {
        _coreDataController = coreDataController;
    }
    return self;
}

- (void)main {
    NSManagedObjectContext *backgroundObjectContext = [[self coreDataController] createBackgroundQueueContext];
    [backgroundObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DeletedCloudKitObject"]; // TODO
        NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        
        NSError *error = nil;
        NSPersistentStoreResult *result = nil;
        result = [backgroundObjectContext executeRequest:deleteRequest error:&error];
        
        if (result == nil) { // TODO??
            // TODO throw exception
            return;
        }
        [[self coreDataController] saveBackgroundQueueContext:backgroundObjectContext];
    }];
}



@end
