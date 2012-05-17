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
@property (nonatomic, retain) Tester *tester;

//Core Data
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

//Get all entites
- (NSArray *)allEntitiesForName:(NSString *)entityName;

//Google
- (Tester *)createTester;
- (Tester *)updateTesterWithStatus:(NSString *)status updateTime:(NSDate *)date;
@end
