//
//  DeletedCloudKitObject+CoreDataProperties.h
//  Places
//
//  Created by Christian Wen on 10/21/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "DeletedCloudKitObject+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DeletedCloudKitObject (CoreDataProperties)

+ (NSFetchRequest<DeletedCloudKitObject *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *recordID;
@property (nullable, nonatomic, copy) NSString *recordType;

@end

NS_ASSUME_NONNULL_END
