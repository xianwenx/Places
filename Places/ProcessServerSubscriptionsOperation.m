//
//  ProcessServerSubscriptionsOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "ProcessServerSubscriptionsOperation.h"
#import <CloudKit/CloudKit.h>
#import "CloudKitZone.h"

@implementation ProcessServerSubscriptionsOperation

- (instancetype)init {
    if ((self = [super init])) {
        _preProcessFetchedSubscriptions     =   [NSDictionary dictionary];
        _postProcessSubscriptionsToCreate   =   nil;
        _postProcessSubscriptionIDsToDelete =   nil;
    }
    return self;
}

- (void)main {
    [self setSubscriptionsToCreate];
    [self setSubscriptionsToDelete];
}

- (void)setSubscriptionsToCreate {
    // TODO
    NSSet *serverSubscriptionZoneNamesSet = [self createServerSubscriptionZoneNameSet];
    NSSet *expectedZoneNamesWithSubscriptionsSet = [CloudKitZone allCloudKitZoneNames];
}

- (void)setSubscriptionsToDelete {
    NSSet *serverSubscriptionZoneNamesSet = [self createServerSubscriptionZoneNameSet];
    // TODO
}

- (NSSet *)createServerSubscriptionZoneNameSet {
    NSArray         *serverSubscriptions        =   [[self preProcessFetchedSubscriptions] allValues];
    NSMutableArray  *serverSubscriptionZoneIDs  =   [NSMutableArray array];
    for (CKRecordZoneSubscription *subscription in serverSubscriptions) { // TODO deprecated?
        CKRecordZoneID *zoneID = [subscription zoneID];
        [serverSubscriptionZoneIDs addObject:zoneID];
    }
    
    NSMutableSet *serverSubscriptionZoneNamesSet = [NSMutableSet set];
    for (CKRecordZoneID *zoneID in serverSubscriptionZoneIDs) {
        NSString *zoneName = [zoneID zoneName];
        [serverSubscriptionZoneNamesSet addObject:zoneName];
    }
    
    return [serverSubscriptionZoneNamesSet copy];
}

@end
