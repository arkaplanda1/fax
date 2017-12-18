//
//  AppDelegate.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2014 QTS. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonHelper.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "HomeController.h"
#import "CreditVC.h"
#import "SettingVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(![IAPShare sharedHelper].iap) {
        
        NSSet* dataSet = [[NSSet alloc] initWithObjects:IAP_1,IAP_2,IAP_5,IAP_10,IAP_25,IAP_100, nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
        
    }
    [IAPShare sharedHelper].iap.production = NO;

    if (![[NSUserDefaults standardUserDefaults] valueForKey:NUMBER_FAX]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:NUMBER_FAX];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if (![[NSUserDefaults standardUserDefaults] valueForKey:IDENTIFIER]) {
        //        NSString *rand = [CommonHelper randomStringWithLength:10];@"@"0BBC4346-FB64-4F97-A6F4-78B731D68E4C""
        NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:IDENTIFIER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self setupViewControllers];
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    
    [self customizeInterface];
    
    return YES;
}


#pragma mark - Methods

- (void)setupViewControllers {
    UIViewController *firstViewController = [[HomeController alloc] initWithNibName:@"HomeController" bundle:nil];
    UIViewController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:firstViewController];
    
    UIViewController *secondViewController = [[CreditVC alloc] initWithNibName:@"CreditVC" bundle:nil];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:secondViewController];
    
    UIViewController *thirdViewController = [[SettingVC alloc] initWithNibName:@"SettingVC" bundle:nil];
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:thirdViewController];
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController]];
    self.viewController = tabBarController;
    
    [self customizeTabBarForController:tabBarController];
}

- (void)setTabbarHidden:(BOOL)isHidden{
    RDVTabBarController *tabBarController = (RDVTabBarController*)self.viewController;
//    tabBarController.tabBar.hidden = isHidden;
    [tabBarController setTabBarHidden:isHidden];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"icoFax", @"icoBuyCredit", @"icoSettings"];
    NSArray *tabBarItemTitles = @[NSLocalizedString(@"TXT_HOME",nil), NSLocalizedString(@"TXT__BUY_CREDIT",nil), NSLocalizedString(@"TXT_SETTING",nil)];

    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        item.title = [tabBarItemTitles objectAtIndex:index];
        item.tintColor = [UIColor whiteColor];
        index++;
    }
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}

/*!
 * @discussion Set data to NSUserDeaults
 * @param strValue Dictionary Value for given key
 * @param strKey Key-name for storing values
 */
-(void)SetData:(NSString *)strValue value:(NSString *)strKey
{
    [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/*!
 * @discussion Get data from NSUserDeaults
 * @param strKey Key-name for getting values
 * @return value for given key
 */
-(NSString *)GetData:(NSString *)strKey
{
    if ([[NSUserDefaults standardUserDefaults]
         stringForKey:strKey]!=nil)
    {
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:strKey];
        return  savedValue;
        
    }
    else
    {
        return  @"";
    }
    
    
}
/*!
 * @discussion Remove key-value pair from NSUserDeaults
 * @param strKey Key-name for removing values
 */
-(void)RemoveData:(NSString *)strKey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
