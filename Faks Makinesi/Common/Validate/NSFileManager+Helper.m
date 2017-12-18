//
//  NSFileManager+Helper.m
//  
//
//  Created by Henry on 4/4/13.
//  Copyright (c) 2013 Henry. All rights reserved.
//

#import "NSFileManager+Helper.h"
#import "HelperFramework.h"
#import "NSString+Helper.h"

@implementation NSFileManager (Helper)

+(void) createFolder:(NSString *)folder agreeToReplaceIfExist:(BOOL)agree{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![NSString checkSpecialCharacter:folder]){
            NSString *pathLD = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
            NSFileManager *mFile = [NSFileManager defaultManager];
            if (![mFile fileExistsAtPath:pathLD]){
                [mFile createDirectoryAtPath:pathLD withIntermediateDirectories:NO attributes:nil error:nil];
                [HelperFramework saveFolderUserdefault:folder];
            }else{
                if(agree){
                    [mFile removeItemAtPath:folder error:nil];
                    [mFile createDirectoryAtPath:pathLD withIntermediateDirectories:NO attributes:nil error:nil];
                    [HelperFramework saveFolderUserdefault:folder];
                }
            }
        }else{
            NSLog(@"Can't create this folder. A file name can't contain any of the following character special.");
        }
    });
}

+(unsigned long long int) getSizeOfFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if (![mFile fileExistsAtPath:folderPath]){
        NSArray *filesArray = [mFile subpathsOfDirectoryAtPath:folderPath error:nil];
        NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
        NSString *fileName;
        unsigned long long int fileSize = 0;
        while (fileName = [filesEnumerator nextObject]) {
            NSDictionary *fileDictionary = [mFile attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
            fileSize += [fileDictionary fileSize];
        }
        return fileSize;
    }
    return 0;
}

+(void) deleteFile:(NSString *)file inFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:file];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if ([mFile fileExistsAtPath:filePath]){
        [mFile removeItemAtPath:filePath error:nil];
    }
}

+(void) deleteFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if ([mFile fileExistsAtPath:folderPath]){
        [mFile removeItemAtPath:folderPath error:nil];
        [HelperFramework deleteFolderUserdefault:folder];
    }
}

+(BOOL) isExistFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if ([mFile fileExistsAtPath:folderPath]){
        return YES;
    }
    return NO;
}

+(BOOL) isExistFile:(NSString *)file inFolder:(NSString *)folder{
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:file];
    NSFileManager *mFile = [NSFileManager defaultManager];
    if ([mFile fileExistsAtPath:filePath]){
        return YES;
    }
    return NO;
}

+(void) deleteAllFileInFolder:(NSString *)folder{
    NSFileManager *mFile = [NSFileManager defaultManager];
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    if ([mFile fileExistsAtPath:folderPath]){
        for (NSString *file in [mFile contentsOfDirectoryAtPath:folderPath error:nil])
        {
            NSString *filePath = [folderPath stringByAppendingPathComponent:file];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            
        }
    }
}

+(void) addFile:(NSData *)data fileName:(NSString *)file intoFolder:(NSString *)folder{
    NSFileManager *mFile = [NSFileManager defaultManager];
    NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
    if(![mFile fileExistsAtPath:folderPath]){
        [self createFolder:folder agreeToReplaceIfExist:YES];
    }
    if([data length]){
        NSString *pathLD = [folderPath stringByAppendingPathComponent:file];
        [data writeToFile:pathLD atomically:YES];
    }
}

+(NSArray *) allFolder{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allFolders = nil;
    if([defaults objectForKey:KEY_FILE_MANAGER]!=nil){
        allFolders = (NSMutableArray *)[defaults objectForKey:KEY_FILE_MANAGER];
    }
    return allFolders;
}

+(NSData *) getFileWithName:(NSString *)file inFolder:(NSString *)folder{
    if([self isExistFile:file inFolder:folder]){
        NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]];
        NSString *filePath = [folderPath stringByAppendingPathComponent:file];
        return [NSData dataWithContentsOfFile:filePath];
    }
    return nil;
}

+(NSString *) urlFileName:(NSString *)fileName inFolder:(NSString *)folder{
    return [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folder]] stringByAppendingPathComponent:fileName];
}

@end
