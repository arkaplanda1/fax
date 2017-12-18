//
//  NSString+Helper.h
//  
//
//  Created by Henry on 4/3/13.
//  Copyright (c) 2013 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

+ (NSString *)stringByTrimString:(NSString *)string;

+ (NSString *)stringByMD5Decrypter:(NSString *)string;

+ (BOOL)checkSpecialCharacter:(NSString *)string;

+ (NSString *)stringFromBase64String:(NSString *)string;

+ (NSString *)base64StringFromString:(NSString*)string;

+ (NSString *)base64DataFromData:(NSData *)data;

+ (NSData *)dataFromBase64Data:(NSData*)base64Data;

@end
