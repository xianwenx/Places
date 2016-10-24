//
//  CloudKitController.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CoreDataController;
@interface CloudKitController : NSObject
- (instancetype)initWithCoreDataController:(CoreDataController *)coreDataController;
- (void)saveChangesToCloudKit:(NSArray *)insertedObjectIDs
            modifiedObjectIDs:(NSArray *)modifiedObjectIDs
             deletedRecordIDs:(NSArray *)deletedRecordIDs;

- (void)performFullSync;
@property (nonatomic, readwrite, strong) NSDate *lastCloudKitSyncTimeStamp;
@end
