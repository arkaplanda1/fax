//
//  SettingVC.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "SettingVC.h"
#import "CreditVC.h"
#import "HistoryVC.h"
#import "ContactUSVC.h"
#import <MessageUI/MFMailComposeViewController.h>

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SettingVC ()
@end

@implementation SettingVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];

    self.lblHistory.text =[NSString stringWithFormat:@"+ %@",NSLocalizedString(@"TXT_FAX_HISTORY",nil)];
     self.lblShareApp.text = [NSString stringWithFormat:@"+ %@",NSLocalizedString(@"TXT_SHARE",nil)];
     self.lblRateApp.text =[NSString stringWithFormat:@"+ %@",NSLocalizedString(@"TXT_WRITE_COMMENT",nil)];
     self.lblOtherApp.text = [NSString stringWithFormat:@"+ %@",NSLocalizedString(@"TXT_OTHERAPP",nil)];
     self.lblContact.text = [NSString stringWithFormat:@"+ %@",NSLocalizedString(@"TXT_CONTACTUS",nil)];

    int sizeText = 27;
    
    [self.lblContact setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    [self.lblHistory setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    [self.lblOtherApp setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    [self.lblRateApp setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    [self.lblShareApp setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lblCredit.text = NSLocalizedString(@"TXT_CREDITS",nil);
    self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doHistory:(id)sender {
    HistoryVC *historyVC=[[HistoryVC alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (IBAction)doContact:(id)sender {
    ContactUSVC *contactVC =[[ContactUSVC alloc] init];
    [self.navigationController pushViewController:contactVC animated:YES];
}

- (IBAction)btnCredit_pressed:(UIButton *)sender {
    CreditVC *creditVc =[[CreditVC alloc] init];
    [self.navigationController pushViewController:creditVc animated:YES];
}

- (IBAction)doOtherApp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/tr/artist/erkan-eroglu/id667357099"]];
}

- (IBAction)doRateApp:(id)sender {
    NSString *strAppUrl =[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",ID_APP];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:strAppUrl]];
}

- (IBAction)doShareApp:(id)sender {
    NSArray *objectsToShare = @[NSLocalizedString(@"TXT_APP_SHARE",nil),[NSURL URLWithString:APP_LINK]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
