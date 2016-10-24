//
//  CloudKitZone.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "CloudKitZone.h"

@interface CloudKitZone ()
@property (nonatomic, readwrite, copy) NSString *recordType;
@end

@implementation CloudKitZone

+ (instancetype)placeZone {
    return [[self alloc] initWithRecordType:@"Place"];
}

- (instancetype)init {
    return [self initWithRecordType:nil];
}

- (instancetype)initWithRecordType:(NSString *)recordType {
    if ([[[self class] allCloudKitZoneNames] containsObject:recordType]) {
        if ((self = [super init])) {
            _recordType = recordType;
        }
    }
    return self;
}

- (NSString *)serverTokenDefaultsKey {
    NSString    *result         =   nil;
    
    result                      =   [[self recordType] stringByAppendingString:@"ServerChangeTokenKey"];
    return result;
}

- (CKRecordZoneID *)recordZoneID {
    CKRecordZoneID  *result     =   nil;
    
    result                      =  [[CKRecordZoneID alloc] initWithZoneName:[self recordType]
                                                                  ownerName:CKCurrentUserDefaultName];
    return result;
}

- (CKNotificationInfo *)notificationInfo {
    CKNotificationInfo *result = nil;
    [result setAlertBody:@"Subscription notification"]; // TODO
    [result setShouldSendContentAvailable:YES];
    [result setShouldBadge:NO];
    return result;
}

- (CKRecordZoneSubscription *)cloudKitSubscription {
    CKRecordZoneSubscription  *result     =   nil;
    
    result = [[CKRecordZoneSubscription alloc] initWithZoneID:[self recordZoneID]];
    [result setNotificationInfo:[self notificationInfo]];
    
    return result;
}

- (NSString *)zoneName {
    return [self recordType];
}

+ (NSSet *)allCloudKitZoneNames {
    return [NSSet setWithObject:@"Place"];
}

@end
