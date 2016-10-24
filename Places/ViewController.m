//
//  ViewController.m
//  Places
//
//  Created by Christian Wen on 10/20/16.
//  Copyright © 2016 edgarchu. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataControlling.h"
#import "Place+CoreDataClass.h"
@interface ViewController () <CoreDataControlling>

@end

@implementation ViewController
@synthesize coreDataController = _coreDataController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSManagedObjectContext *managedObjectContext = [[[self coreDataController] persistentContainer] viewContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];

    // Do any additional setup after loading the view, typically from a nib.
    [self reloadData];
}

- (void)reloadData {
    NSFetchRequest *fetchRequest = [Place fetchRequest];
    NSError *error = nil;
    
    NSArray *array = [[[[self coreDataController] persistentContainer] viewContext] executeFetchRequest:fetchRequest error:&error];
    NSLog(@"array: %@");

}

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
    [self reloadData];
}

- (void)managedObjectContextWillSave:(NSNotification *)notification {
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
}

- (void)dealloc {
    NSManagedObjectContext *managedObjectContext = [[[self coreDataController] persistentContainer] viewContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}



@end
