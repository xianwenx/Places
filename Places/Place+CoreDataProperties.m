//
//  Place+CoreDataProperties.m
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "Place+CoreDataProperties.h"

@implementation Place (CoreDataProperties)

+ (NSFetchRequest<Place *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Place"];
}

@dynamic name;
@dynamic latitude;
@dynamic longitude;

@end
