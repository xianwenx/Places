//
//  CloudKitManagedObject.m
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "CloudKitManagedObject.h"
#import "DeletedCloudKitObject+CoreDataClass.h"

@implementation CloudKitManagedObject
@synthesize added       =   _added;
@synthesize lastUpdate  =   _lastUpdate;
@synthesize recordName  =   _recordName;
@synthesize recordType  =   _recordType;

- (CKRecord *)cloudKitRecord:(nullable CKRecord *)record
       forParentRecordZoneID:(nullable CKRecordZoneID *)parentRecordZoneID {
    
    CKRecord        *result         = record;
    CKRecordZoneID  *recordZoneID   = parentRecordZoneID;

    if (record == nil) {
        if (parentRecordZoneID == nil) {
            recordZoneID            = [[CKRecordZoneID alloc] initWithZoneName:[self recordType]
                                                                     ownerName:CKCurrentUserDefaultName];

        }
        
        NSUUID      *uuid           =  [[NSUUID alloc] init];
        NSString    *recordName     =  [NSString stringWithFormat:@"%@.%@", [self recordName], [uuid UUIDString]];
        CKRecordID  *recordID       = [[CKRecordID alloc] initWithRecordName:recordName zoneID:recordZoneID];
        
        result = [[CKRecord alloc] initWithRecordType:[self recordType] recordID:recordID];
    }
    
    
    return result;
    
}

- (void)addDeletedCloudKitObject {
    NSManagedObjectContext  *managedObjectContext   =   [self managedObjectContext];
    NSData                  *recordID               =   [self recordID];
    NSString                *recordType             =   [self recordType];
    NSManagedObject         *deletedCloudKitObject  =   nil;
    
    deletedCloudKitObject = [NSEntityDescription insertNewObjectForEntityForName:@"DeletedCloudKitObject"
                                                                         inManagedObjectContext:managedObjectContext];
    if ([deletedCloudKitObject isKindOfClass:[DeletedCloudKitObject class]]) {
        [((DeletedCloudKitObject *) deletedCloudKitObject) setRecordID:recordID];
        [((DeletedCloudKitObject *) deletedCloudKitObject) setRecordType:recordType];
    }
}
@end
