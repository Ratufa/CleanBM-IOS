//
//  HomeViewController.h
//  CleanBM
//
//  Created by Developer on 03/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"

@interface HomeViewController : UIViewController
{
    
}
@property (strong, readonly, nonatomic) REMenu *menu;
@property (nonatomic,readwrite)NSInteger requestFor;
@property (nonatomic ,retain)NSString *strSearchLocation;

@property (nonatomic ,readwrite)double latitude;
@property (nonatomic ,readwrite)double longitude;


@end
