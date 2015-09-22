//
//  AddNewLocationViewController.h
//  CleanBM
//
//  Created by Developer on 11/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddNewLocationViewController : UIViewController
{
    
}

@property (nonatomic ,readwrite)int requestFor;
@property (nonatomic ,strong)NSMutableDictionary *mDictRestaurantHotelDetail;
@property (nonatomic ,strong)NSString *strRequestFor;


@property (nonatomic ,strong)NSMutableArray *mArrayReviewsList;
@property (nonatomic ,retain)NSString *strBathRoomId;
@property (nonatomic ,strong)PFObject *bathRoomDetail;

@end
