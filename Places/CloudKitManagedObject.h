//
//  CloudKitManagedObject.h
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>
#import "CloudKitRecordIDObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface CloudKitManagedObject : CloudKitRecordIDObject
@property (nonatomic, readwrite, strong, nullable)  NSDate      *added;
@property (nonatomic, readwrite, strong, nullable)  NSDate      *lastUpdate;
@property (nonatomic, readwrite, copy, nullable)    NSString    *recordName;
@property (nonatomic, readwrite, copy)              NSString    *recordType;

- (CKRecord *)managedObjectToRecord:(nullable CKRecord *)record;
- (void)updateWithRecord:(CKRecord *)record;

- (CKRecord *)cloudKitRecord:(nullable CKRecord *)record
       forParentRecordZoneID:(nullable CKRecordZoneID *)parentRecordZoneID;

- (void)addDeletedCloudKitObject;
@end

NS_ASSUME_NONNULL_END
