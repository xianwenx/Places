//
//  FetchAllSubscriptionsOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface FetchAllSubscriptionsOperation : CKFetchSubscriptionsOperation
@property (nonatomic, readwrite, strong) NSDictionary *fetchedSubscriptions;
@end
