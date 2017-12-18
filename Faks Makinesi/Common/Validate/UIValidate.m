//
//  UIValidate.m


#import "UIValidate.h"
#import "NSString+Helper.h"

@implementation UIValidate

+ (BOOL) validateEmail:(NSString *)email
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL) validateText:(NSString *)text minimumLength:(int)length{
    if([[NSString stringByTrimString:text] length] < length){
        return FALSE;
    }
    return TRUE;
}

+ (BOOL) validateUrl: (NSString *)candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

+(BOOL) validateNumric:(NSString*)input{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:input];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}


@end
