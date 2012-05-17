//
//  DataManager.m
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import "DataManager.h"

#define kTesterEntity @"Tester"
@implementation DataManager

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

@synthesize tester = _tester;

- (id)init {
    self = [super init];
    if (self) {
        self.tester = [self createTester];
        [self saveContext];
    }
    return self;
}

#pragma mark - Test Google
- (Tester *)createTester {
    Tester *aTester = nil;
    NSArray *prevoiusTesters = [self allEntitiesForName:kTesterEntity];
    if (prevoiusTesters.count) {
        aTester = [prevoiusTesters objectAtIndex:0];
    } else {
        aTester = [NSEntityDescription insertNewObjectForEntityForName:kTesterEntity inManagedObjectContext:self.managedObjectContext];
    }
    return aTester;
}

- (Tester *)updateTesterWithStatus:(NSString *)status updateTime:(NSDate *)date {
    self.tester.status = status;
    self.tester.updateTime = date;
    return self.tester;
}

#pragma mark - All Entities
- (NSArray *)allEntitiesForName:(NSString *)entityName {
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
	//Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSError *error = nil;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];    
    [request release];
    
    if (!error) {
        return results;
    }
    return [NSArray array];
}


#pragma mark - Core Data stack
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Storage" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Storage.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])    {
    }        
    return __persistentStoreCoordinator;
}

- (void)saveContext {      
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                if (error != nil) {
                    NSLog(@"%@", error);
                    abort();
                }
            } 
        }    
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)dealloc {
    [_tester release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

@end
