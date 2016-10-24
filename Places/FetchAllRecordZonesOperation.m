//
//  FetchAllRecordZonesOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "FetchAllRecordZonesOperation.h"


@implementation FetchAllRecordZonesOperation

- (void)main {
    [self setOperationBlocks];
    [super main];
}

- (void)setOperationBlocks {
    __weak typeof(self) weakSelf = self;
    [self setFetchRecordZonesCompletionBlock:^(NSDictionary<CKRecordZoneID *,CKRecordZone *> *recordZones, NSError *error) {
        typeof(self) strongSelf = weakSelf;
        if (error != nil) {
            return;
            // TODO error
        }
        
        if (recordZones != nil) {
            [strongSelf setFetchedRecordZones:recordZones];
        }
    }];
}

@end
