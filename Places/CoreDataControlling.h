//
//  CoreDataViewController.h
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataController.h"

@protocol CoreDataControlling <NSObject>
@property (nonatomic, readwrite, strong) CoreDataController *coreDataController;
@end
