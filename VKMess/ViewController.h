//
//  ViewController.h
//  VKMess
//
//  Created by Serg Krivoblotsky on 3/9/12.
//  Copyright (c) 2012 Onix-Systems, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewControllerExtended <RequestHandlerDelegate>
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *updateLabel;

@end
