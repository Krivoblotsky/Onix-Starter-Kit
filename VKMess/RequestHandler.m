//
//  RequestHandler.m
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import "RequestHandler.h"

@implementation RequestHandler
@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        dataManager = (ApplicationDelegate).dataManager;
        server = [[RemoteServer alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - Server Callbacks
- (void)askGoogleForSomething:(NSString *)query {
    [server askGoogleForSomething:query responceCallback:@selector(askGoogleRequestFinished:)];
}

- (void)askGoogleRequestFinished:(id)responce {
    [dataManager updateTesterWithStatus:@"Updated" updateTime:[NSDate date]];
    [dataManager saveContext];
    
    if ([self.delegate respondsToSelector:@selector(askGoogleRequestFinished)]) {
        [self.delegate askGoogleRequestFinished];
    }
}

- (void)server:(RemoteServer *)aServer didFailWithError:(NSError *)error {
    NSLog(@"Fail - %@", aServer);
}

- (void)dealloc {
    [server release];
    [super dealloc];
}

@end
