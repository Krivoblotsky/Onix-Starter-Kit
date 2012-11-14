//
//  UIViewControllerExtended.h
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface UIViewControllerExtended : UIViewController <RequestHandlerDelegate> {
    AppDelegate *appDelegate;
    RequestHandler *_requestHandler;
}
@property (nonatomic, weak) DataManager *dataManager;
@property (nonatomic, retain) RequestHandler *requestHandler;

- (void)commonInit;
@end
