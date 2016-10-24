//
//  CloudKitZone.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface CloudKitZone : NSObject
@property (nonatomic, readwrite, copy)  NSString                    *zoneName;
@property (nonatomic, readonly, copy)   NSString                    *serverTokenDefaultsKey;
@property (nonatomic, readonly, strong) CKRecordZoneID              *recordZoneID;
@property (nonatomic, readonly, strong) CKNotificationInfo          *notificationInfo;
@property (nonatomic, readonly, strong) CKRecordZoneSubscription    *cloudKitSubscription;

- (instancetype)initWithRecordType:(NSString *)recordType;
+ (instancetype)placeZone;
+ (NSSet *)allCloudKitZoneNames;
@end
