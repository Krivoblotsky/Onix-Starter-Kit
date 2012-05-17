//
//  AppDelegate.h
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ViewController;
@class DataManager;
@class RequestHandler;
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    DataManager *dataManager;
    RequestHandler *requestHandler;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) RequestHandler *requestHandler;

@property (strong, nonatomic) ViewController *viewController;

@end
