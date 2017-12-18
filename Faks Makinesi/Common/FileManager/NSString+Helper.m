//
//  NSString+Helper.m
//  
//
//  Created by Henry on 4/3/13.
//  Copyright (c) 2013 Henry. All rights reserved.
//

#import "NSString+Helper.h"
#import <CommonCrypto/CommonDigest.h>


static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };


@implementation NSString (Helper)

+(NSString *) stringByTrimString:(NSString *)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSString *) stringByMD5Decrypter:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString  stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12],
            result[13], result[14], result[15]
            ];
}

+(BOOL) checkSpecialCharacter:(NSString *)string{
    NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];
    
    if ([string.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
        return YES;
    }
    return NO;
}

#pragma mark - Base64String

+ (NSString *)stringFromBase64String:(NSString *)string
{
    NSData *base64Data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *plainTextData = [self dataFromBase64Data:base64Data];
    NSString *plainText = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
    return plainText;
}

+ (NSString *)base64StringFromString:(NSString*)string
{
    NSData *base64Data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *plainText = [self base64DataFromData:base64Data];
    return plainText;
}

+ (NSString *)base64DataFromData:(NSData *)data
{
	const unsigned char *bytes = [data bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[data length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	unsigned short i = 0;
	unsigned short charsonline = 0, ctcopy = 0;
	unsigned long ix = 0;
	
	while (YES) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
		
		for (i = 0; i < 3; i++) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
		
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
		
		switch (ctremaining) {
			case 1: ctcopy = 2; break;
			case 2: ctcopy = 3; break;
		}
		
		for (i = 0; i < ctcopy; i++)
			[result appendFormat:@"%c", encodingTable[outbuf[i]]];
		
		for (i = ctcopy; i < 4; i++)
			[result appendString:@"="];
		
		ixtext += 3;
		charsonline += 4;
	}
	
	return [NSString stringWithString:result];
}

+ (NSData *)dataFromBase64Data:(NSData*)base64Data
{
	const unsigned char *bytes = [base64Data bytes];
	NSMutableData *result = [NSMutableData dataWithCapacity:[base64Data length]];
	
	unsigned long ixtext = 0;
	unsigned long lentext = [base64Data length];
	unsigned char ch = 0;
	unsigned char inbuf[4], outbuf[3];
	short i = 0, ixinbuf = 0;
	BOOL flignore = NO;
	BOOL flendtext = NO;
	
	while (YES) {
		if (ixtext >= lentext) break;
		ch = bytes[ixtext++];
		flignore = NO;
		
		if      (ch >= 'A' && ch <= 'Z') ch = ch - 'A';
		else if (ch >= 'a' && ch <= 'z') ch = ch - 'a' + 26;
		else if (ch >= '0' && ch <= '9') ch = ch - '0' + 52;
		else if (ch == '+')              ch = 62;
		else if (ch == '=')              flendtext = YES;
		else if (ch == '/')              ch = 63;
		else flignore = YES;
		
		if (!flignore) {
			short ctcharsinbuf = 3;
			BOOL flbreak = NO;
			
			if (flendtext) {
				if (!ixinbuf) break;
				if (ixinbuf == 1 || ixinbuf == 2) ctcharsinbuf = 1;
				else ctcharsinbuf = 2;
				ixinbuf = 3;
				flbreak = YES;
			}
			
			inbuf[ixinbuf++] = ch;
			
			if (ixinbuf == 4) {
				ixinbuf = 0;
				outbuf [0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
				outbuf [1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C ) >> 2);
				outbuf [2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
				
				for (i = 0; i < ctcharsinbuf; i++)
					[result appendBytes:&outbuf[i] length:1];
			}
			
			if (flbreak) break;
		}
	}
	
	return [NSData dataWithData:result];
}

@end
