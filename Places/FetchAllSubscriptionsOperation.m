//
//  FetchAllSubscriptionsOperation.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "FetchAllSubscriptionsOperation.h"

@implementation FetchAllSubscriptionsOperation

- (instancetype)init {
    if ((self = [super init])) {
        _fetchedSubscriptions = [NSDictionary dictionary];
    }
    return self;
}

- (void)main {
    [self setOperationBlocks];
    [super main];
}

- (void)setOperationBlocks {
    __weak typeof(self) weakSelf = self;
    [self setFetchSubscriptionCompletionBlock:^(NSDictionary<NSString *,CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (error != nil) {
            // TODO
        }
        
        if (subscriptions != nil) {
            [strongSelf setFetchedSubscriptions:subscriptions];
            for (NSString *subscriptionID in [subscriptions allKeys]) {
                NSLog(@"fetched subscription: %@", subscriptionID);
            }
        }
        
    }];
}
@end
