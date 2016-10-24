//
//  FetchRecordChangesForCloudKitZoneOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "FetchRecordChangesForCloudKitZoneOperation.h"


@interface FetchRecordChangesForCloudKitZoneOperation ()
@property (nonatomic, readwrite, strong) CloudKitZone *cloudKitZone;

@end


@implementation FetchRecordChangesForCloudKitZoneOperation

- (instancetype)init {
    return [self initWithCloudKitZone:nil];
}

- (instancetype)initWithCloudKitZone:(CloudKitZone *)cloudKitZone {
    if ((self = [super init])) {
        _cloudKitZone       = cloudKitZone;
        _changedRecords     = [NSArray array];
        _deletedRecordIDs   = [NSArray array];

        [self setRecordZoneID:[[CKRecordZoneID alloc] initWithZoneName:[cloudKitZone zoneName]
                                                             ownerName:CKCurrentUserDefaultName]];
        
        [self setPreviousServerChangeToken:[self serverChangeToken:cloudKitZone]];
    }
    return self;
}

- (void)main {
    [self setOperationBlocks];
    [super main];
}

- (void)setOperationBlocks {
    __weak typeof(self) weakSelf = self;
    [self setRecordChangedBlock:^(CKRecord * _Nonnull record) {
        __strong typeof(self) strongSelf = weakSelf;
        NSArray *appendedChangedRecords = [[strongSelf changedRecords] arrayByAddingObject:record];
        [strongSelf setChangedRecords:appendedChangedRecords];
    }];
    
    [self setRecordWithIDWasDeletedBlock:^(CKRecordID * _Nonnull recordID) {
        __strong typeof(self) strongSelf = weakSelf;
        NSArray *appendedDeletedRecordIDs = [[strongSelf deletedRecordIDs] arrayByAddingObject:recordID];
        [strongSelf setDeletedRecordIDs:appendedDeletedRecordIDs];
    }];
    
    [self setFetchRecordChangesCompletionBlock:^(CKServerChangeToken * _Nullable serverChangeToken,
                                                 NSData * _Nullable clientChangeToken,
                                                 NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;

        if (error != nil) {
            [strongSelf setOperationError:error];
        } else {
            [strongSelf setServerChangeToken:[strongSelf cloudKitZone] serverChangeToken:serverChangeToken];
        }
        
    }];
}

- (CKServerChangeToken *)serverChangeToken:(CloudKitZone *)cloudKitZone {
    CKServerChangeToken *result = nil;
    NSString *serverTokenDefaultsKey = [cloudKitZone serverTokenDefaultsKey];
    NSData *encodedObjectData = [[NSUserDefaults standardUserDefaults] objectForKey:serverTokenDefaultsKey];
    if (encodedObjectData != nil) {
        id unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObjectData];
        if ([unarchivedObject isKindOfClass:[CKServerChangeToken class]]) {
            result = unarchivedObject;
        }
    }
    return result;
}

- (void)setServerChangeToken:(CloudKitZone *)cloudKitZone serverChangeToken:(CKServerChangeToken *)serverChangeToken {
    NSString *serverTokenDefaultsKey = [cloudKitZone serverTokenDefaultsKey];
    if (serverChangeToken != nil) {
        NSData *archivedServerChangeToken = [NSKeyedArchiver archivedDataWithRootObject:serverChangeToken];
        [[NSUserDefaults standardUserDefaults] setObject:archivedServerChangeToken forKey:serverTokenDefaultsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:serverTokenDefaultsKey];
    }
}


@end
