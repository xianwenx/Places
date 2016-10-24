//
//  ProcessServerRecordZonesOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProcessServerRecordZonesOperation : NSOperation
@property (nonatomic, readwrite, strong) NSMutableArray *preProcessRecordZoneIDs;
@property (nonatomic, readwrite, strong) NSMutableArray *postProcessRecordZonesToCreate;
@property (nonatomic, readwrite, strong) NSMutableArray *postProcessRecordZoneIDsToDelete;
@end
