//
//  ProcessServerRecordZonesOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "ProcessServerRecordZonesOperation.h"
#import <CloudKit/CloudKit.h>
#import "CloudKitZone.h"
@implementation ProcessServerRecordZonesOperation

- (instancetype)init {
    if ((self = [super init])) {
        _preProcessRecordZoneIDs = [NSMutableArray array];
    }
    return self;
}

- (void)main {
    [self setZonesToCreate];
    [self setZonesToDelete];
}

- (void)setZonesToCreate {
    NSMutableSet *serverZoneNamesSet = [NSMutableSet set];
    for (CKRecordZoneID *recordZoneID in [self preProcessRecordZoneIDs]) {
        [serverZoneNamesSet addObject:[recordZoneID zoneName]];
    }
    
    NSSet *expectedZoneNamesSet = [CloudKitZone allCloudKitZoneNames];
    NSMutableSet *missingZoneNamesSet = [expectedZoneNamesSet mutableCopy];
    
    [missingZoneNamesSet minusSet:serverZoneNamesSet];
    
    if ([missingZoneNamesSet count] > 0) {
        [self setPostProcessRecordZonesToCreate:[NSMutableArray array]];
        for (NSString *zoneName in missingZoneNamesSet) {
            CloudKitZone *zone = [[CloudKitZone alloc] initWithRecordType:zoneName];
            if (zone != nil) {
                CKRecordZone *missingRecordZone = [[CKRecordZone alloc] initWithZoneID:[zone recordZoneID]];
                [[self postProcessRecordZonesToCreate] addObject:missingRecordZone];
            }
        }

    }
   }

- (void)setZonesToDelete {
    for (CKRecordZoneID *recordZoneID in [self preProcessRecordZoneIDs]) {
        if ([[recordZoneID zoneName] isEqualToString:CKRecordZoneDefaultName] == NO && [[CloudKitZone alloc] initWithRecordType:[recordZoneID zoneName]] == nil)  {
            if ([self postProcessRecordZoneIDsToDelete] == nil) {
                [self setPostProcessRecordZoneIDsToDelete:[NSMutableArray array]];
            }
            [[self postProcessRecordZoneIDsToDelete] addObject:recordZoneID];
        }
    }
}

@end
