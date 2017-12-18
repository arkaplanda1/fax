
#import <Foundation/Foundation.h>

@interface UIValidate : NSObject

+ (BOOL) validateEmail:(NSString *)email ;

+ (BOOL) validateText:(NSString *)text minimumLength:(int)length;

+ (BOOL) validateUrl: (NSString *)candidate;

+ (BOOL) validateNumric:(NSString*)input;

@end
