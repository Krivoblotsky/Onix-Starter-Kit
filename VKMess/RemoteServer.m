//
//  VKServer.m
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import "RemoteServer.h"
#import "XMLReader.h"

@implementation RemoteServer

#define kTestURL @"http://taxi.rocketfirm.com/ru/taxi/city/1"

@synthesize delegate;
@synthesize dataManager;
@synthesize networkQue = _networkQue;
@synthesize dataType = _dataType;

- (id)initWithDelegate:(id <RemoteServerDelegate>) aDelegate {
    self = [super init];
    if (self) {
        self.dataManager = (ApplicationDelegate).dataManager;
        //Assign delegate
        self.delegate = aDelegate;
        
        //JSON parser
        jsonParser = [SBJSON new];
        
        //NetworkQue
        _networkQue = [[ASINetworkQueue alloc] init];
        [_networkQue setShowAccurateProgress:YES]; 
        [_networkQue setDelegate:self];
        [_networkQue setRequestDidFailSelector:@selector(requestDidFail:)];
        
        //Set data type
        _dataType = DataTypeJSON;
    }
    return self;
}

#pragma mark - Test request
- (void)askGoogleForSomething:(NSString *)query responceCallback:(SEL)callback {
    NSString *url = [NSString stringWithFormat:kTestURL];
    ASIHTTPRequest *request = [self requestWithURL:url postValues:nil didFinishSelector:callback];
    [self addRequestToQue:request];
}

- (void)askGoogleRequestFinished:(ASIHTTPRequest *)request {
    [self validateRequest:request forSelector:_cmd];
}

#pragma mark - Misc
- (ASIHTTPRequest *)requestWithURL:(NSString *)url postValues:(NSDictionary *)postData didFinishSelector:(SEL)selector {
    if (postData == nil) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestDidFail:)];
        [request setDidFinishSelector:selector];
        return request;
    } else {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestDidFail:)];
        [request setDidFinishSelector:selector];        
        NSArray *keys = [postData allKeys];
        for (NSString *key in keys) {
            NSString *postValue = [postData objectForKey:key];
            [request addPostValue:postValue forKey:key];
        }
        return request;
    }
    return nil;
}

- (void)addRequestToQue:(ASIHTTPRequest *)request {
    [_networkQue addOperation:request];
    if ([_networkQue isSuspended]) {
        [_networkQue go];
    }
}

- (void)validateRequest:(ASIHTTPRequest *)request forSelector:(SEL)selector {
    //Check for status code
    if (request.responseStatusCode != 200) {
        [self requestDidFail:request];
        return;
    }
    
    NSError *parseError = nil;
    id result = nil;
    
    if (self.dataType == DataTypeXML) {
        result = [XMLReader dictionaryForXMLString:request.responseString error:&parseError];
    } else if (self.dataType == DataTypeJSON) {
        result = [jsonParser objectWithString:request.responseString error:&parseError];        
    }
    if (!parseError && result != nil) {
        if ([self.delegate respondsToSelector:selector]) {
            [self.delegate performSelector:selector withObject:result];
        }
    } else {
        [self requestDidFail:request];
    }
}

- (void)requestDidFail:(ASIHTTPRequest *)request {
    if ([self.delegate respondsToSelector:@selector(server:didFailWithError:)]) {
        [self.delegate server:self didFailWithError:request.error];
    }
}


#pragma mark - Memory Release
- (void)dealloc {
    [_networkQue cancelAllOperations];
    [_networkQue release];
    [jsonParser release];
    [super dealloc];
}

@end
