//
//  FetchAllRecordZonesOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <CloudKit/CloudKit.h>

@interface FetchAllRecordZonesOperation : CKFetchRecordZonesOperation
@property (nonatomic, readwrite, strong) NSDictionary *fetchedRecordZones;
@end
