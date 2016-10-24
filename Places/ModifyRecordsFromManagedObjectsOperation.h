//
//  ModifyRecordsFromManagedObjectsOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"
#import "CloudKitController.h"

@interface ModifyRecordsFromManagedObjectsOperation : CKModifyRecordsOperation
@property (nonatomic, readwrite, strong) NSDictionary   *fetchedRecordsToModify;
@property (nonatomic, readwrite, strong) NSArray        *preModifiedRecords;

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                        cloudKitController:(CloudKitController *)cloudKitController;

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                        cloudKitController:(CloudKitController *)cloudKitController
                  modifiedManagedObjectIDs:(NSArray *)modifiedManagedObjectIDs
                          deletedRecordIDs:(NSArray *)deletedRecordIDs;


@end
