//
//  Common.m


#import "CommonHelper.h"
#import "RoyalIndicator.h"
#import "Reachability.h"
@implementation CommonHelper 
+ (AppDelegate *)appDelegate
{
    UIApplication *app = [UIApplication sharedApplication];
    return (AppDelegate *)app.delegate;
}

+ (void)showAlert:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"TXT_OK",nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    [alertController addAction:cancelAction];
    
    [[CommonHelper appDelegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertWithBlock:(NSString *)message block:(void(^)(void))block
{
    UIAlertController *alertController = [UIAlertController
                                    alertControllerWithTitle:@""
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"TXT_OK",nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       block();
                                   }];
    [alertController addAction:cancelAction];
    
    [[CommonHelper appDelegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showBusyView
{
    
    AppDelegate *delegate= (AppDelegate *) [UIApplication sharedApplication].delegate;
    [RoyalIndicatorWindow royalIndicatorForView:delegate.window withLabel:@""];
}

+ (void)hideBusyView
{
    [RoyalIndicatorWindow removeViewAnimated:YES];
}

+ (BOOL) connectedInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

+ (BOOL)isNumber:(NSString *)input{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([input rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        return YES;
    }
    return NO;
}


+ (NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+ (UIImage*)applyBWFilter:(UIImage *)image
{
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIImage *blackAndWhite = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.1], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
    CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", [NSNumber numberWithFloat:0.7], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    //UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(cgiimage);
    
    return newImage;
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [CommonHelper imageWithImage:image scaledToSize:newSize];
}

@end
