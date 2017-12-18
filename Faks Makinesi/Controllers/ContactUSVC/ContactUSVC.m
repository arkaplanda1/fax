//
//  ContactUSVC.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "ContactUSVC.h"
#import "CreditVC.h"
#import "UIValidate.h"
#import "CommonHelper.h"
#import <CFNetwork/CFNetwork.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "JSON.h"

#define IS_IPHONE_4_SCREEN() ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
@interface ContactUSVC ()<UITextFieldDelegate, UITextViewDelegate>

@end

@implementation ContactUSVC

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

    self.lblCredit.text = NSLocalizedString(@"TXT_CREDITS",nil);
    self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];
    [self.btnBuyCredit setTitle:NSLocalizedString(@"TXT_SEND",nil) forState:UIControlStateNormal];
    self.lblMail.text =[NSString stringWithFormat:@"%@:", NSLocalizedString(@"TXT_EMAIL",nil)];
    self.lblContent.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"TXT_MESSAGE",nil)];
    
    int sizeText = 29;
    
    for (UILabel *lb in self.arrLabels) {
        [lb setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    }
    [self.txfEmail setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    [self.txfContent setFont:[UIFont fontWithName:FONT_NAME size:sizeText]];
    [self.btnBuyCredit.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:29]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCredit_pressed:(UIButton *)sender {
    CreditVC *creditVc =[[CreditVC alloc] init];
    [self.navigationController pushViewController:creditVc animated:YES];
}

- (IBAction)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doIAP:(id)sender {
    [self doSend:sender];
}
-(NSString *) stringByTrimString:(NSString *)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (IBAction)doSend:(id)sender {
    NSString *strEmail = [self stringByTrimString:self.txfEmail.text];
    NSString *StrContent =[self stringByTrimString:self.txfContent.text];
    if (![UIValidate validateEmail:strEmail]) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_INVALID_MAIL",nil)];
        [self.txfEmail becomeFirstResponder];
    }else if (StrContent.length ==0)
    {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_MESSAGE_IS_REQUIRED",nil)];
        [self.txfContent becomeFirstResponder];
    }
    else
    {
        [self.txfEmail resignFirstResponder];
        [self.txfContent resignFirstResponder];
        [self.scrollPage setContentOffset:CGPointMake(0,0)];
        if (![CommonHelper connectedInternet]) {
            [CommonHelper showAlert:NSLocalizedString(@"TXT_NETWORK", nil)];
            return;
        }
        [self callWS:strEmail andMsg:StrContent];
    }
}

- (IBAction)touchScroll:(id)sender {
    [self.txfEmail resignFirstResponder];
    [self.txfContent resignFirstResponder];
    [self.scrollPage setContentOffset:CGPointMake(0,0)];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField ==self.txfEmail) {
        [self.txfContent becomeFirstResponder];
    }
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollPage setContentOffset:CGPointMake(0,150)];
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self.scrollPage setContentOffset:CGPointMake(0,200)];
}

-(void) callWS:(NSString *) email andMsg:(NSString *) msg
{
    [CommonHelper showBusyView];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:LINK_WS]];
    NSDictionary *parameter = @{@"mail":email,@"msg":msg};
    NSURLRequest *request = [httpClient requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/fax-mail.php",LINK_WS] parameters:parameter];
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Success
        
        [CommonHelper  hideBusyView];
        [CommonHelper showAlert:NSLocalizedString(@"TXT_MESSAGE_SENDT",nil)];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [CommonHelper showAlert:error.description];
        NSLog(@"AFHTTPRequestOperation Failure: %@", error);
        [CommonHelper hideBusyView];
        
    }];
    [operation start];

}
@end
