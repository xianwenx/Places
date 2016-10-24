//
//  ProcessSyncChangesOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"

@interface ProcessSyncChangesOperation : NSOperation
@property (nonatomic, readwrite, strong) NSMutableArray *preProcessLocalChangedObjectIDs;
@property (nonatomic, readwrite, strong) NSMutableArray *preProcessLocalDeletedRecordIDs;
@property (nonatomic, readwrite, strong) NSMutableArray *preProcessServerChangedRecords;
@property (nonatomic, readwrite, strong) NSMutableArray *preProcessServerDeletedRecordIDs;

@property (nonatomic, readwrite, strong) NSMutableArray *postProcessChangesToCoreData;
@property (nonatomic, readwrite, strong) NSMutableArray *postProcessChangesToServer;
@property (nonatomic, readwrite, strong) NSMutableArray *postProcessDeletesToCoreData;
@property (nonatomic, readwrite, strong) NSMutableArray *postProcessDeletesToServer;

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController;

@end
