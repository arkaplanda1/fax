//
//  iAPVerification.c
//  Fax
//
//  Created by Антон Буков on 06.06.16.
//  Copyright © 2016 QTS. All rights reserved.
//

#include "NSMutableURLRequest+Parameters.h"
#include "iAPVerification.h"

static NSString *const kServerURL = @"http://hemakgroup.com/faxnew/verify.php";

@implementation iAPVerification

+ (void)verifyPurchase:(SKPaymentTransaction *)paymentTransaction isSandbox:(BOOL)sandbox delegate:(id<iAPVerificationDelegate>)delegate {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerURL]];
    request.HTTPMethod = @"POST";
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    if (![[NSFileManager defaultManager] fileExistsAtPath:receiptUrl.path]) {
        NSLog(@"Refreshing receipt");
        SKReceiptRefreshRequest *refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
        [refreshReceiptRequest start];
        if ([delegate respondsToSelector:@selector(verificationFailed:error:paymentTransaction:)]) {
            [delegate verificationFailed:iAPConnectionFailed error:nil paymentTransaction:paymentTransaction];
        }
        return;
    }
    NSData *receiptData = paymentTransaction.transactionReceipt;//[NSData dataWithContentsOfURL:receiptUrl];//; //
    request.parameters = @{@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER], @"receipt":[receiptData base64EncodedStringWithOptions:0] ?: [NSNull null]};
    NSLog(@"Sending receipt to server = %@", [receiptData base64EncodedStringWithOptions:0]);
    
    __weak id<iAPVerificationDelegate> weak_delegate = delegate;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id<iAPVerificationDelegate> delegate = weak_delegate;
            
            if (error || !data) {
                NSLog(@"Received error from server = %@", error);
                if ([delegate respondsToSelector:@selector(verificationFailed:error:paymentTransaction:)]) {
                    [delegate verificationFailed:iAPConnectionFailed error:error paymentTransaction:paymentTransaction];
                }
                return;
            }
            
            NSString *answer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Received answer from server = %@", answer);
            if (![answer isEqualToString:@"0"]) {
                if ([delegate respondsToSelector:@selector(verificationFailed:error:paymentTransaction:)]) {
                    [delegate verificationFailed:iAPVerificationFailed error:error paymentTransaction:paymentTransaction];
                }
                return;
            }
            
            if ([delegate respondsToSelector:@selector(purchaseVerified:paymentTransaction:)]) {
                [delegate purchaseVerified:@{@"product_id":paymentTransaction.transactionIdentifier} paymentTransaction:paymentTransaction];
                [[NetworkService createInstance] checkCredit:^(int credits) {
                }];
            }
        });
    }] resume];
}

+ (void)verifyPurchase:(SKPaymentTransaction *)paymentTransaction serverUrl:(NSString *)urlString isSandbox:(BOOL)sandbox delegate:(id<iAPVerificationDelegate>)delegate {
    NSAssert(NO, @"Need to be inplemented");
}

+ (BOOL)findBinaries {
    return NO;
}

@end
