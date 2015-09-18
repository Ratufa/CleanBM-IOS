//
//  AppDelegate.m
//  CleanBM
//
//  Created by Developer on 16/07/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//ratufa.CleamBM
//com.ratufa.restaurant

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <AddressBook/AddressBook.h>
#import "ViewController.h"
#import "Constant.h"


@interface AppDelegate ()<CLLocationManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"n2FEMcVdsaoobBxDypgkxF7uSQ3tYBrtDJ4F15zZ"
                  clientKey:@"iqHFj1h4QAoy9H3N2jgDg7xAVszinTZV433TxkCt"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    //Location Manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];

    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _strRequestFor = @"NearMe";
    
    _strRootOrLogin = @"RootViewController";
    
    
    NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    
    NSString *devId= [[uniqueIdentifier description]
                      stringByReplacingOccurrencesOfString:@"-" withString:@""]
    ;
    
    [[NSUserDefaults standardUserDefaults]setObject:devId forKey:@"DeviceId"];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark-- Shared Instance
+(AppDelegate *)getInstance{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude] forKey:@"longitude"];
          [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude] forKey:@"latitude"];
        
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark * placemark in placemarks) {
                NSDictionary *addressDictionary = [placemark addressDictionary];
                NSString *city = addressDictionary[(NSString *)kABPersonAddressCityKey];
                NSString *state = addressDictionary[(NSString *)kABPersonAddressStateKey];
                NSString *country = placemark.country;
                NSString *zipcode = addressDictionary [(NSString *)kABPersonAddressZIPKey];
                
                NSString *strStreet = placemark.subLocality;
                
                NSString *strAddress = [NSString stringWithFormat:@"%@,%@",city,state];
                [[NSUserDefaults standardUserDefaults] setValue:strAddress forKey:@"Address"];
                NSString *strAddAtrind = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",strStreet,city,state,country,zipcode];
                [[NSUserDefaults standardUserDefaults] setValue:city forKey:@"userCity"];
                [[NSUserDefaults standardUserDefaults] setValue:state forKey:@"userState"];
                [[NSUserDefaults standardUserDefaults] setValue:country forKey:@"userCountry"];
                [[NSUserDefaults standardUserDefaults] setValue:zipcode forKey:@"userZipcode"];
                
                [[NSUserDefaults standardUserDefaults] setValue:strAddAtrind forKey:@"FullAddress"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    }
}

@end
