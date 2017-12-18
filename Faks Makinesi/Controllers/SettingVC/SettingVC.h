//
//  SettingVC.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingVC : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPage;
@property(nonatomic,assign) BOOL isSetting;
@property (strong, nonatomic) IBOutlet UILabel *lblHistory;
@property (strong, nonatomic) IBOutlet UILabel *lblShareApp;
@property (strong, nonatomic) IBOutlet UILabel *lblRateApp;
@property (strong, nonatomic) IBOutlet UILabel *lblOtherApp;
@property (strong, nonatomic) IBOutlet UILabel *lblContact;
@property (strong, nonatomic) IBOutlet UILabel *lblCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCount;

- (IBAction)doHistory:(id)sender;
- (IBAction)doContact:(id)sender;
- (IBAction)doOtherApp:(id)sender;
- (IBAction)doRateApp:(id)sender;
- (IBAction)doShareApp:(id)sender;

@end
