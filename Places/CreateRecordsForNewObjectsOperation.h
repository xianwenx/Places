//
//  CreateRecordsForNewObjectsOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"

@interface CreateRecordsForNewObjectsOperation : NSOperation
@property (nonatomic, readonly, strong) NSArray *createdRecords;
- (instancetype)initWithInsertedManagedObjectIDs:(NSArray *)insertedManagedObjectIDs
                              coreDataController:(CoreDataController *)coreDataController;
@end
