//
//  NetworkService.h
//  Fax
//
//  Created by Milan Mendpara on 27/11/17.
//  Copyright © 2017 QTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryObj.h"

@interface NetworkService : NSObject

+ (id) createInstance;

- (void)checkCredit:(void(^)(int credits))callback;

- (void)getCountryCode:(void(^)(int code))callback;

- (void)getCountries:(void(^)(NSArray *contries))callback;

- (void)checkNumber:(NSString *)countryCode number:(NSString *)number callback:(void(^)(BOOL isValid))callback;

- (void)getFaxCount:(void(^)(int count))callback;

- (void)getFaxDetail:(int)number callback:(void(^)(HistoryObj *detail))callback;

- (void)deleteFax:(int)number callback:(void(^)(void))callback;

@end
