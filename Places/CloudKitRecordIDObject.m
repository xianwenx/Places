//
//  CloudKitRecordIDObject.m
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "CloudKitRecordIDObject.h"

@implementation CloudKitRecordIDObject
@synthesize recordID = _recordID;


- (CKRecordID *)cloudKitRecordID {
    CKRecordID    *result             =   nil;
    NSData      *recordID           =   [self recordID];

    id          unarchivedObject    =   nil;
    
    if (recordID) {
        unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithData:recordID];
        if ([unarchivedObject isKindOfClass:[CKRecord class]]) {
            result = (CKRecordID *) unarchivedObject;
        }
    }
    
    return result;
}
@end
