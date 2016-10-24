//
//  DeletedCloudKitObject+CoreDataProperties.m
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "DeletedCloudKitObject+CoreDataProperties.h"

@implementation DeletedCloudKitObject (CoreDataProperties)

+ (NSFetchRequest<DeletedCloudKitObject *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DeletedCloudKitObject"];
}

@dynamic recordID;
@dynamic recordType;

@end
