//
//  HelperFramework.h
//  
//
//  Created by Henry on 4/5/13.
//  Copyright (c) 2013 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_FILE_MANAGER @"676234d1cc61113ad84aaf7f7fe40004"

@interface HelperFramework : NSObject

+(void) saveFolderUserdefault:(NSString *)folder;
+(void) deleteFolderUserdefault:(NSString *)folder;

@end
