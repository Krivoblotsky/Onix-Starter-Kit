//
//  UIViewControllerExtended.m
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import "UIViewControllerExtended.h"
#import "RequestHandler.h"
#import "DejalActivityView.h"

@implementation UIViewControllerExtended
@synthesize requestHandler = _requestHandler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];        
    }
    return self;
}

- (void)commonInit {
    self.dataManager = (ApplicationDelegate).dataManager;
    
    _requestHandler = [[RequestHandler alloc] init];
    _requestHandler.delegate = self;
}

#pragma mark - Handler
- (void)requestHandler:(RequestHandler *)handler didFailWithError:(NSError *)error {
    NSLog(@"H: %@", handler);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
