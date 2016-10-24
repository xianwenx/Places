//
//  SaveChangedRecordsToCoreDataOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"
@interface SaveChangedRecordsToCoreDataOperation : NSOperation
@property (nonatomic, readwrite, strong) NSArray             *changedRecords;
@property (nonatomic, readwrite, strong) NSArray             *deletedRecordIDs;

- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController;
@end
