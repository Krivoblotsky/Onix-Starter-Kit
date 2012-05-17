//
//  Tester.h
//  StartKit
//
//  Created by Serg Krivoblotsky on 4/4/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tester : NSManagedObject

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * updateTime;

@end
