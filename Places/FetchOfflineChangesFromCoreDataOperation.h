//
//  FetchOfflineChangesFromCoreDataOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudKitController.h"
#import "CoreDataController.h"


@interface FetchOfflineChangesFromCoreDataOperation : NSOperation
@property (nonatomic, readonly, strong) NSMutableArray *updatedManagedObjectIDs;
@property (nonatomic, readonly, strong) NSArray *deletedRecordIDs;

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController
                        cloudKitController:(CloudKitController *)cloudKitController
                               entityNames:(NSArray *)entityNames;

@end
