//
//  Common.h


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface CommonHelper : NSObject
+ (AppDelegate *)appDelegate;
+ (void)showAlert:(NSString *)message;
+ (void)showBusyView;
+ (void)hideBusyView;
+ (BOOL) connectedInternet;
+ (BOOL)isNumber:(NSString *)input;
+ (void)showAlertWithBlock:(NSString *)message block:(void(^)(void))block;
+ (UIImage*)applyBWFilter:(UIImage *)image;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
+ (NSString *) randomStringWithLength: (int) len;

@end
