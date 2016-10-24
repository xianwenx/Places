//
//  CloudKitRecordIDObject.h
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
@interface CloudKitRecordIDObject : NSManagedObject
@property (nonatomic, readwrite, copy) NSData *recordID;
- (CKRecordID *)cloudKitRecordID;
@end
