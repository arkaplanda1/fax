//
//  NetworkService.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 27/11/17.
//  Copyright © 2017 QTS. All rights reserved.
//

#import "NetworkService.h"
#import <CFNetwork/CFNetwork.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "JSON.h"

@implementation NetworkService

static NetworkService * _networkService;

+ (id) createInstance
{
    if(!_networkService){
        _networkService = [NetworkService new];
    }
    return _networkService;
}

+ (AFHTTPClient *)getHTTPClient{
    return [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:LINK_WS]];
}

+ (void)executeAPI:(NSURLRequest *)request callback:(void(^)(NSString *responseString))callback{
    [CommonHelper showBusyView];
    AFHTTPRequestOperation *operation = [[NetworkService getHTTPClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(operation.responseString);
        NSLog(@"Res %@",operation.responseString);
        [CommonHelper  hideBusyView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonHelper showAlert:error.description];
        NSLog(@"AFHTTPRequestOperation Failure: %@", error);
        [CommonHelper hideBusyView];
    }];
    [operation start];
}

- (void)checkCredit:(void(^)(int credits))callback{
    NSDictionary *parameter = @{@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/fax_credit_check.php",LINK_WS] parameters:parameter];

    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        if ([CommonHelper isNumber:responseString]){
            [[NSUserDefaults standardUserDefaults] setValue:responseString forKey:NUMBER_FAX];
            callback([responseString intValue]);
        }
    }];
}

- (void)getCountryCode:(void(^)(int code))callback{
    NSDictionary *parameter = @{@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"GET" path:[NSString stringWithFormat:@"%@/unknownnumbers/autocountrycode.php",LINK_WS] parameters:parameter];
    
    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        NSArray *arrValues = [responseString componentsSeparatedByString:@","];
        if ([CommonHelper isNumber:[arrValues objectAtIndex:0]])
            callback([[arrValues objectAtIndex:0] intValue]);
        else
            callback(0);
    }];
}

- (void)getCountries:(void(^)(NSArray *contries))callback{
    NSDictionary *parameter = @{@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"GET" path:[NSString stringWithFormat:@"%@/faxnew/countries.json",LINK_WS] parameters:parameter];
    
    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        NSDictionary *dic = [responseString JSONValue];
        if ([[dic allKeys] containsObject:@"countries"]) {
            callback([dic objectForKey:@"countries"]);
        }
    }];
}


- (void)checkNumber:(NSString *)countryCode number:(NSString *)number callback:(void(^)(BOOL isValid))callback{
    NSDictionary *parameter = @{@"countrycode":countryCode,@"number":number};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/verifynumber.php",LINK_WS] parameters:parameter];
    
    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        callback([responseString isEqualToString:@"0"]);
    }];
}

- (void)getFaxCount:(void(^)(int count))callback{
    NSDictionary *parameter = @{@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/countfax.php",LINK_WS] parameters:parameter];
    
    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        if ([CommonHelper isNumber:responseString])
            callback([responseString intValue]);
        else
            callback(0);
    }];
}

- (void)getFaxDetail:(int)number callback:(void(^)(HistoryObj *detail))callback{
    NSDictionary *parameter = @{@"faxno":[@(number) stringValue], @"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/faxdetail.php",LINK_WS] parameters:parameter];
    
    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        
        NSArray *arr =[responseString JSONValue];
        if (arr.count == 5) {
            int duration = 0;
            NSString *strDuration = [@"" stringByAppendingFormat:@"%@",arr[1]];
            if ([CommonHelper isNumber:strDuration]){
                duration = [strDuration intValue];
            }
            NSString *dur = NSLocalizedString(@"TXT_WAIT",nil);
            if (duration > 0)
                dur = [@(duration) stringValue];
            
            double status = -1;
            NSString *strStatus = [@"" stringByAppendingFormat:@"%@",arr[3]];

            if ([CommonHelper isNumber:strStatus]){
                status = [strStatus doubleValue];
            }
            NSString *st = NSLocalizedString(@"TXT_WAIT",nil);
            if (status == 0)
                st = NSLocalizedString(@"TXT_COMPLETED",nil);
            else if (status == 263 || status == 3931 || status == 8025)
                st = NSLocalizedString(@"TXT_BUSY",nil);
            else if (status == 3935 || status == 8021)
                st = NSLocalizedString(@"TXT_NO_ANSWER",nil);
            else if (status < 0)
                st = NSLocalizedString(@"TXT_WAIT",nil);
            else
                st = NSLocalizedString(@"TXT_FAXMACHINE_ERROR",nil);

            HistoryObj *history = [HistoryObj new];
            history.date = arr[0];
            history.duration = dur;
            history.faxnumber = arr[2];
            history.status = st;
            history.imageUrl =  [[@"" stringByAppendingFormat:@"%@",arr[4]] stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
            
            callback(history);
        }
    }];
}

- (void)deleteFax:(int)number callback:(void(^)(void))callback{
    NSDictionary *parameter = @{@"faxno":[@(number) stringValue], @"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSURLRequest *request = [[NetworkService getHTTPClient] requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/faxdelete.php",LINK_WS] parameters:parameter];
    
    [NetworkService executeAPI:request callback:^(NSString *responseString) {
        if ([responseString isEqualToString:@"1"]) {
            callback();
        }
    }];
}
@end
