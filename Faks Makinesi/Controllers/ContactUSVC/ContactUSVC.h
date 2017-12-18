//
//  ContactUSVC.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUSVC : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPage;
@property (strong, nonatomic) IBOutlet UITextField *txfEmail;
@property (strong, nonatomic) IBOutlet UITextView *txfContent;
@property (strong, nonatomic) IBOutlet UILabel *lblMail;
@property (strong, nonatomic) IBOutlet UILabel *lblContent;
@property (strong, nonatomic) IBOutlet UILabel *lblCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCount;
@property (strong, nonatomic) IBOutlet UIButton *btnBuyCredit;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabels;
- (IBAction)doBack:(id)sender;
- (IBAction)doIAP:(id)sender;
- (IBAction)touchScroll:(id)sender;

@end
