//
//  CreditVC.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditVC : UIViewController
@property(nonatomic,assign) BOOL isCredit;
@property (strong, nonatomic) IBOutlet UILabel *lblCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCount;
@property (strong, nonatomic) IBOutlet UILabel *lbl1Fask;
@property (strong, nonatomic) IBOutlet UILabel *lbl3Faks;
@property (strong, nonatomic) IBOutlet UILabel *lbl5faks;
@property (weak, nonatomic) IBOutlet UILabel *lbl10Faks;
@property (weak, nonatomic) IBOutlet UILabel *lbl25Faks;
@property (weak, nonatomic) IBOutlet UILabel *lbl100Faks;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *llblPrice1;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice2;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice3;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice4;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice5;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice6;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrPrice;
- (IBAction)doBuy:(id)sender;

@end
