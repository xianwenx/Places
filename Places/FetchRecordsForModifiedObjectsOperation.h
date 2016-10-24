//
//  FetchRecordsForModifiedObjectsOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "CoreDataController.h"

@interface FetchRecordsForModifiedObjectsOperation : CKFetchRecordsOperation
@property (nonatomic, readwrite, strong) NSDictionary   *fetchedRecords;
@property (nonatomic, readwrite, strong) NSArray        *preFetchModifiedRecords;


- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                  modifiedManagedObjectIDs:(NSArray *)modifiedManagedObjectIDs;
- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController;
@end
