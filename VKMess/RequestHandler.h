//
//  RequestHandler.h
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "RemoteServer.h"

@protocol RequestHandlerDelegate;
@interface RequestHandler : NSObject <RemoteServerDelegate> {
    DataManager *dataManager;
    RemoteServer *server;
}
@property (nonatomic, assign) id <RequestHandlerDelegate> delegate;

//Calls
- (void)askGoogleForSomething:(NSString *)query;
@end

@protocol RequestHandlerDelegate <NSObject>
@required
- (void)requestHandler:(RequestHandler *)handler didFailWithError:(NSError *)error;
@optional
- (void)askGoogleRequestFinished;
@end