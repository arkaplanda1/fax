//
//  NSFileManager+Helper.h
//  
//
//  Created by Henry on 4/4/13.
//  Copyright (c) 2013 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Helper)

+(void) createFolder:(NSString *)folder agreeToReplaceIfExist:(BOOL)agree;
+(void) deleteFile:(NSString *)file inFolder:(NSString *)folder;
+(void) deleteFolder:(NSString *)folder;
+(void) deleteAllFileInFolder:(NSString *)folder;
+(void) addFile:(NSData *)data fileName:(NSString *)file intoFolder:(NSString *)folder;
+(BOOL) isExistFolder:(NSString *)folder;
+(BOOL) isExistFile:(NSString *)file inFolder:(NSString *)folder;
+(unsigned long long int) getSizeOfFolder:(NSString *)folder;
+(NSArray *) allFolder;
+(NSData *) getFileWithName:(NSString *)file inFolder:(NSString *)folder;
+(NSString *) urlFileName:(NSString *)fileName inFolder:(NSString *)folder;
@end
