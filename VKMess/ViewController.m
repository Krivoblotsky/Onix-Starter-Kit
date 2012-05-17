//
//  ViewController.m
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import "ViewController.h"
#import "DejalActivityView.h"

@implementation ViewController
@synthesize statusLabel;
@synthesize updateLabel;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark - Reload
- (void)reloadData {
    self.statusLabel.text = self.dataManager.tester.status;
    self.updateLabel.text = [self.dataManager.tester.updateTime description];
}

#pragma marm - Test
- (IBAction)test:(id)sender {   
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Requesting..."];
    [_requestHandler askGoogleForSomething:@"Hello"];
}

- (void)askGoogleRequestFinished {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self reloadData];
}

- (void)requestHandler:(RequestHandler *)handler didFailWithError:(NSError *)error {
    self.statusLabel.text = @"Error";
}

#pragma mark - Cleanup
- (void)viewDidUnload {
    [self setStatusLabel:nil];
    [self setUpdateLabel:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [statusLabel release];
    [updateLabel release];
    [super dealloc];
}
@end
