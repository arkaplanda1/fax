//
//  CreditVC.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "CreditVC.h"
#import "SettingVC.h"
#import "IAPHelper.h"
#import "CommonHelper.h"
#include "NSMutableURLRequest+Parameters.h"

@interface CreditVC ()
{
    int _indexPurchase;
    NSMutableArray  *products;
}
@end

@implementation CreditVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lblCredit.text = NSLocalizedString(@"TXT_CREDITS",nil);
    self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];

    [self.scrollView setContentSize:CGSizeMake(ScreenWidth, 310)];

    [[CommonHelper appDelegate] setTabbarHidden:NO];
    
    products =[[NSMutableArray alloc] init];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchasedSuccesfully:) name:IAPHelperProductPurchasedNotification object:nil];

    for (UILabel *lb in self.arrPrice) {
        [lb setFont:[UIFont fontWithName:FONT_NAME size:22]];
    }
    [self GetIAPsItems];
    // Do any additional setup after loading the view from its nib.
}
-(void) GetIAPsItems{
    if (![CommonHelper connectedInternet]) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_NETWORK", nil)];
    }
    else
    {
        [CommonHelper showBusyView];
        
        [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
         {
             if ([response.products count]>0) {
                 NSLog(@"Iaps Items: %@",response.products);
                 [products setArray:response.products];
                 [self getPrice];
             } else {
             }
             [CommonHelper hideBusyView];
         }];
//        [[PeowIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *p) {
//            if (success) {
//                if ([p count]>0) {
//                    NSLog(@"Iaps Items: %@",p);
//                    [products setArray:p];
//                    [self getPrice];
//                    [CommonHelper hideBusyView];
//                } else {
//                }
//            } else {
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Unable to connect to AppStore. Please check your internet connection" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//                [alert show];
//                [CommonHelper hideBusyView];
//            }
//        }];
    }
}

-(void) getPrice
{
    SKProduct *product =[products objectAtIndex:2];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:product.priceLocale];
    
    self.llblPrice1.text =[NSString stringWithFormat:@"%@ %@",product.price,[formatter currencySymbol]];
    
    SKProduct *product1 =[products objectAtIndex:4];
    NSNumberFormatter *formatter1    = [[NSNumberFormatter alloc] init];
    [formatter1 setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter1 setLocale:product1.priceLocale];

    self.lblPrice2.text =[NSString stringWithFormat:@"%@ %@",product1.price,[formatter currencySymbol]];
    
    SKProduct *product2 =[products objectAtIndex:1];
    
    NSNumberFormatter *formatter2 = [[NSNumberFormatter alloc] init];
    [formatter2 setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter2 setLocale:product2.priceLocale];

    self.lblPrice4.text =[NSString stringWithFormat:@"%@ %@",product2.price,[formatter currencySymbol]];

    SKProduct *product3 =[products objectAtIndex:3];
    
    NSNumberFormatter *formatter3 = [[NSNumberFormatter alloc] init];
    [formatter3 setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter3 setLocale:product3.priceLocale];
    
    self.lblPrice5.text =[NSString stringWithFormat:@"%@ %@",product3.price,[formatter currencySymbol]];

    SKProduct *product4 =[products objectAtIndex:0];
    
    NSNumberFormatter *formatter4 = [[NSNumberFormatter alloc] init];
    [formatter4 setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter4 setLocale:product4.priceLocale];

    self.lblPrice6.text =[NSString stringWithFormat:@"%@ %@",product4.price,[formatter currencySymbol]];

    SKProduct *product5 =[products objectAtIndex:5];
    
    NSNumberFormatter *formatter5 = [[NSNumberFormatter alloc] init];
    [formatter5 setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter5 setLocale:product5.priceLocale];

    self.lblPrice3.text =[NSString stringWithFormat:@"%@ %@",product5.price,[formatter currencySymbol]];

    self.lbl1Fask.text = [NSString stringWithFormat:@"1 %@ = 1 %@",NSLocalizedString(@"TXT_CREDIT",nil),NSLocalizedString(@"TXT_FAX",nil)];
    self.lbl3Faks.text = [NSString stringWithFormat:@"2 %@ = 2 %@",NSLocalizedString(@"TXT_CREDIT",nil),NSLocalizedString(@"TXT_FAX",nil)];
    self.lbl5faks.text = [NSString stringWithFormat:@"5 %@ = 5 %@",NSLocalizedString(@"TXT_CREDIT",nil),NSLocalizedString(@"TXT_FAX",nil)];
    self.lbl10Faks.text =  [NSString stringWithFormat:@"10 %@ = 10 %@",NSLocalizedString(@"TXT_CREDIT",nil),NSLocalizedString(@"TXT_FAX",nil)];
    self.lbl25Faks.text =  [NSString stringWithFormat:@"25 %@ = 25 %@",NSLocalizedString(@"TXT_CREDIT",nil),NSLocalizedString(@"TXT_FAX",nil)];
    self.lbl100Faks.text = [NSString stringWithFormat:@"100 %@ = 100 %@",NSLocalizedString(@"TXT_CREDIT",nil),NSLocalizedString(@"TXT_FAX",nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doBuy:(id)sender {
    UIButton *btn = (UIButton *) sender;
    _indexPurchase = btn.tag+1;
    if (![CommonHelper connectedInternet]) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_NETWORK", nil)];
        return;
    }
    if ([self isJailbroken]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Do not support for jailbroken device"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil];
        [alert show];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/LocalIAPStore.dylib"]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Do not support for jailbroken device"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        NSArray *arrIdentifier = [NSArray arrayWithObjects:IAP_1,IAP_2,IAP_5,IAP_10,IAP_25,IAP_100, nil];
        //bool checkBuy = false;
        NSLog(@"Items selected: |||%@||||",[arrIdentifier objectAtIndex:btn.tag]);
        for (SKProduct *product in products )
        {
            NSLog(@"---%@----", product.productIdentifier);
            if ([product.productIdentifier isEqualToString:[arrIdentifier objectAtIndex:btn.tag]])
            {
                [CommonHelper showBusyView];
                [[IAPShare sharedHelper].iap buyProduct:product
                                           onCompletion:^(SKPaymentTransaction* trans){
                       [CommonHelper hideBusyView];
                       if(trans.error)
                       {
                           [CommonHelper showAlert:[trans.error localizedDescription]];
                           NSLog(@"Fail %@",[trans.error localizedDescription]);
                       }
                       else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                           [self verifyPurchase];
                           [[IAPShare sharedHelper].iap checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:@"your sharesecret" onCompletion:^(NSString *response, NSError *error) {
                               
                               //Convert JSON String to NSDictionary
                               NSDictionary* rec = [IAPShare toJSON:response];
                               
                               if([rec[@"status"] integerValue]==0)
                               {
                                   
                                   [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                   NSLog(@"SUCCESS %@",response);
                                   NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                   [self productPurchasedSuccesfully];
                               }
                               else {
                                   NSLog(@"Fail");
                               }
                           }];
                       }
                       else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                           NSLog(@"Fail");
                           [CommonHelper showAlert:@"Payment Failed"];
                       }
                   }];//end of buy product
                NSLog(@"user has buy package %d", btn.tag);
                break;
            }
//                [[PeowIAPHelper sharedInstance] buyProduct:product];
            }
        }
}

- (void)productPurchasedSuccesfully {
    int numberFax =[[[NSUserDefaults standardUserDefaults] valueForKey:NUMBER_FAX] intValue];
    switch (_indexPurchase) {
        case 1:
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",numberFax+1] forKey:NUMBER_FAX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",numberFax+2] forKey:NUMBER_FAX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 3:
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",numberFax+5] forKey:NUMBER_FAX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 4:
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",numberFax+10] forKey:NUMBER_FAX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 5:
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",numberFax+25] forKey:NUMBER_FAX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 6:
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",numberFax+100] forKey:NUMBER_FAX];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        default:
            break;
    }
    self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];
    [CommonHelper showAlert:NSLocalizedString(@"TXT_PURCHASE_COMPLETE",nil)];
    [CommonHelper hideBusyView];
    
}

- (void)verifyPurchase
{
    NSString *kServerURL = @"http://hemakgroup.com/faxnew/verify.php";

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerURL]];
    request.HTTPMethod = @"POST";
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    if (![[NSFileManager defaultManager] fileExistsAtPath:receiptUrl.path]) {
        NSLog(@"Refreshing receipt");
        SKReceiptRefreshRequest *refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
        [refreshReceiptRequest start];
        return;
    }
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];//; //
    request.parameters = @{@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER], @"receipt":[receiptData base64EncodedStringWithOptions:0] ?: [NSNull null]};
    NSLog(@"Sending receipt to server = %@", [receiptData base64EncodedStringWithOptions:0]);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CommonHelper hideBusyView];
            if (error || !data) {
                [CommonHelper showAlert:[error localizedDescription]];
                NSLog(@"Received error from server = %@", error);
                return;
            }
            
            NSString *answer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Received answer from server = %@", answer);
            if (![answer isEqualToString:@"0"]) {
                [CommonHelper showAlert:@"Server can't verify this receipt"];
                return;
            }
            
            [[NetworkService createInstance] checkCredit:^(int credits) {
            }];
        });
    }] resume];
}

- (BOOL) isJailbroken
{
    
#if TARGET_IPHONE_SIMULATOR
    return NO;
    
#else
    BOOL isJailbroken = NO;
    
    BOOL cydiaInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
    
    FILE *f = fopen("/bin/bash", "r");
    
    if (!(errno == ENOENT) && cydiaInstalled) {
        
        //Device is jailbroken
        isJailbroken = YES;
    }
    fclose(f);
    return isJailbroken;
#endif
}
@end
