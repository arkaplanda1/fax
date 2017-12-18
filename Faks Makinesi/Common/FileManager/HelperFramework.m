//
//  HelperFramework.m
//  
//
//  Created by Henry on 4/5/13.
//  Copyright (c) 2013 Henry. All rights reserved.
//

#import "HelperFramework.h"


@implementation HelperFramework

+(void) saveFolderUserdefault:(NSString *)folder{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allFolders = nil;
    if([defaults objectForKey:KEY_FILE_MANAGER]!=nil){
        allFolders = [(NSMutableArray *)[defaults objectForKey:KEY_FILE_MANAGER] mutableCopy];
    }else{
        allFolders = [NSMutableArray array];
    }
    [allFolders addObject:folder];
    [defaults setObject:allFolders forKey:KEY_FILE_MANAGER];
    [defaults synchronize];
}

+(void) deleteFolderUserdefault:(NSString *)folder{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allFolders = nil;
    if([defaults objectForKey:KEY_FILE_MANAGER]!=nil){
        allFolders = [(NSMutableArray *)[defaults objectForKey:KEY_FILE_MANAGER] mutableCopy];
        if([allFolders containsObject:folder]){
            [allFolders removeObject:folder];
            [defaults setObject:allFolders forKey:KEY_FILE_MANAGER];
            [defaults synchronize];
        }
    }
    
}

@end
