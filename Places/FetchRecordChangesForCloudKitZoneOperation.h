//
//  FetchRecordChangesForCloudKitZoneOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "CloudKitZone.h"

@interface FetchRecordChangesForCloudKitZoneOperation : CKFetchRecordChangesOperation
@property (nonatomic, readwrite, strong) NSArray *changedRecords;
@property (nonatomic, readwrite, strong) NSArray *deletedRecordIDs;
@property (nonatomic, readwrite, strong) NSError *operationError;

- (instancetype)initWithCloudKitZone:(CloudKitZone *)cloudKitZone;

@end
