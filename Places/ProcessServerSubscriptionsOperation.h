//
//  ProcessServerSubscriptionsOperation.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProcessServerSubscriptionsOperation : NSOperation
@property (nonatomic, readwrite, strong) NSDictionary   *preProcessFetchedSubscriptions;
@property (nonatomic, readwrite, strong) NSArray        *postProcessSubscriptionsToCreate;
@property (nonatomic, readwrite, strong) NSArray        *postProcessSubscriptionIDsToDelete;
@end


