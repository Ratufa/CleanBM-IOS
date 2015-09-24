//
//  AppDelegate.h
//  CleanBM
//
//  Created by Developer on 16/07/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BathRoomDetailViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;


@property (nonatomic, strong) FBSDKAccessToken *token;

@property (nonatomic, strong) NSString *strRequestFor;
@property (nonatomic, strong) NSString *strRootOrLogin;
@property (nonatomic, strong) NSString *strMenu;

@property (nonatomic ,strong)BathRoomDetailViewController *bathRoomDetailViewController;

+(AppDelegate *)getInstance;

@property (nonatomic,retain)NSString *imgBathroomId;
@end

