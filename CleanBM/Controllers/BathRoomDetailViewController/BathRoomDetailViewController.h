//
//  BathRoomDetailViewController.h
//  CleanBM
//
//  Created by Developer on 18/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "REMenu.h"
@interface BathRoomDetailViewController : UIViewController
{
    
}
@property(nonatomic ,strong)PFObject *bathRoomDetail;

@property (strong, readonly, nonatomic) REMenu *menu;

@end
