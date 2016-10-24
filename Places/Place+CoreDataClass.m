//
//  Place+CoreDataClass.m
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "Place+CoreDataClass.h"

@implementation Place

- (CKRecord *)managedObjectToRecord:(CKRecord *)record {
    CKRecord *result = nil;
    
    if ([self name] == nil || [self added] == nil || [self lastUpdate] == nil) {
        @throw [NSException exceptionWithName:@"RequiredPropertyNotSetException" reason:@"Required property not est" userInfo:nil];
    }
    
    CKRecord    *placeRecord    = [self cloudKitRecord:record forParentRecordZoneID:nil];
    
    NSString    *recordName     = [[placeRecord recordID] recordName];
    [self setRecordName:recordName];
    
    NSData      *recordID       = [NSKeyedArchiver archivedDataWithRootObject:[placeRecord recordID]];
    [self setRecordID:recordID];
    
    placeRecord[@"name"]        = [self name];
    CLLocation *location        = [[CLLocation alloc] initWithLatitude:[self latitude] longitude:[self longitude]];
    placeRecord[@"location"]    = location;
    placeRecord[@"added"]       = [self added];
    placeRecord[@"lastUpdate"]  = [self lastUpdate];
    
    result = placeRecord;
    return result;
}

- (void)updateWithRecord:(CKRecord *)record {
    [self setName:record[@"name"]];
    [self setAdded:record[@"added"]];
    [self setLastUpdate:record[@"lastUpdate"]];
    [self setRecordName:[[record recordID] recordName]];
    [self setRecordID:[NSKeyedArchiver archivedDataWithRootObject:[record recordID]]];
}

@end
