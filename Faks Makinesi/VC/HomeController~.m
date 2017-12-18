//
//  HomeController.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 25/11/17.
//  Copyright © 2017 QTS. All rights reserved.
//

#import "HomeController.h"
#import "YCameraViewController.h"
#import "ConfirmPictureVC.h"
#import "CreditVC.h"
#import "HistoryVC.h"

@interface HomeController ()<YCameraViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCount;
@property (weak, nonatomic) IBOutlet UIButton *btnSendFax;
@property (weak, nonatomic) IBOutlet UIButton *btnFaxHistory;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.btnSendFax setTitle:NSLocalizedString(@"TXT_SENDFAX",nil) forState:UIControlStateNormal];
    [self.btnFaxHistory setTitle:NSLocalizedString(@"TXT_FAX_HISTORY",nil) forState:UIControlStateNormal];

    // API Call
    
    [[NetworkService createInstance] checkCredit:^(int credits) {
        self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSendFax_pressed:(UIButton *)sender{
    int number =[[[NSUserDefaults standardUserDefaults] valueForKey:NUMBER_FAX] intValue];
    // change controller to push from here
    if (number==0) {
        CreditVC *creditVc =[[CreditVC alloc] init];
        [self.navigationController pushViewController:creditVc animated:YES];
    }
    else
    {
        YCameraViewController *camController = [[YCameraViewController alloc] initWithNibName:@"YCameraViewController" bundle:nil];
        camController.delegate=self;
        [self.navigationController pushViewController:camController animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[CommonHelper appDelegate] setTabbarHidden:NO];
    self.lblCredit.text = NSLocalizedString(@"TXT_CREDITS",nil);
    self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];
}

- (IBAction)btnHistory_pressed:(UIButton *)sender {
    HistoryVC *historyVC =[[HistoryVC alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}
- (IBAction)btnCredit_pressed:(UIButton *)sender {
    CreditVC *creditVc =[[CreditVC alloc] init];
    [self.navigationController pushViewController:creditVc animated:YES];
}

#pragma mark - YCameraViewController Delegate

- (void)didFinishPickingImage:(UIImage *)image{
    ConfirmPictureVC *pictureVC =[[ConfirmPictureVC alloc] init];
    [self.navigationController pushViewController:pictureVC animated:YES];
}

- (void)yCameraControllerdidSkipped{
}

- (void)yCameraControllerDidCancel{
}


@end
