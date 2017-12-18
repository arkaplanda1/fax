//
//  SendEmailVC.h
//  Faks Makinesi
//
//  Created by Nguyen Tuan Cuong on 11/6/14.
//  Copyright (c) 2014 QTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryObj.h"
@interface SendEmailVC : UIViewController
- (IBAction)doCancel:(id)sender;
- (IBAction)doSendEmail:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
@property(nonatomic,retain) HistoryObj *historyObj;

@end
