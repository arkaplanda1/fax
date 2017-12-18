//
//  NSMutableURLRequest+Parameters.h
//  GetFollowers
//
//  Created by Антон Буков on 16.09.15.
//  Copyright © 2015 Codeless Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (Parameters)

@property(nonatomic, retain) NSDictionary *parameters;
@property(nonatomic, readonly) BOOL isMultipart;

- (void)setHTTPBodyWithString:(NSString *)body;

- (void)attachFileWithName:(NSString *)name filename:(NSString*)filename contentType:(NSString *)contentType data:(NSData*)data;

@end
