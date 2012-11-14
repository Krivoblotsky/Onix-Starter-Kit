//
//  DataManager.h
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Tester.h"

@interface DataManager : NSObject {
    Tester *_tester;
}
@property (nonatomic, strong) Tester *tester;

//Core Data
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

//Get all entites
- (NSArray *)allEntitiesForName:(NSString *)entityName;

//Google
- (Tester *)createTester;
- (Tester *)updateTesterWithStatus:(NSString *)status updateTime:(NSDate *)date;
@end
