//
//  VKServer.h
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "SBJSON.h"

enum {
	DataTypeJSON                         = 0,
	DataTypeXML                          = 1,
    DataTypePLIST                        = 2,
    DataTypeOther                        = 3,
};
typedef NSUInteger DataType;

@protocol RemoteServerDelegate;
@interface RemoteServer : NSObject {
    SBJSON *jsonParser;
    ASINetworkQueue *_networkQue;
    
    DataType _dataType;
}
@property (nonatomic, assign) id <RemoteServerDelegate> delegate;
@property (nonatomic, assign) DataManager *dataManager;
@property (nonatomic, retain) ASINetworkQueue *networkQue;
@property DataType dataType;

//Init
- (id)initWithDelegate:(id <RemoteServerDelegate>) aDelegate;

//Calls
- (void)askGoogleForSomething:(NSString *)query responceCallback:(SEL)callback;

//Misc
- (ASIHTTPRequest *)requestWithURL:(NSString *)url postValues:(NSDictionary *)postData didFinishSelector:(SEL)selector;
- (void)addRequestToQue:(ASIHTTPRequest *)request;
- (void)validateRequest:(ASIHTTPRequest *)request forSelector:(SEL)selector;
- (void)requestDidFail:(ASIHTTPRequest *)request;
@end

@protocol RemoteServerDelegate <NSObject>
@required
- (void)server:(RemoteServer *)server didFailWithError:(NSError *)error;

@optional
//Login
- (void)serverDidLoginWithData:(NSDictionary *)loginInfo;

//Friends
- (void)serverDidGetFriends:(NSDictionary *)friendsInfo;
@end