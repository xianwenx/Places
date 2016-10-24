//
//  Place+CoreDataProperties.h
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "Place+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Place (CoreDataProperties)

+ (NSFetchRequest<Place *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

NS_ASSUME_NONNULL_END
