//
//  BathRoomDetail.h
//  CleanBM
//
//  Created by Developer on 15/09/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import <Parse/Parse.h>

@interface BathRoomDetail : PFObject

@property (nonatomic, strong) NSString * objectId;
@property (nonatomic, strong) PFGeoPoint * bathLocation;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * bathRoomType;
@property (nonatomic, strong) NSNumber * bathRating;
@property (nonatomic, strong) NSString * bathFullAddress;
@property (nonatomic, strong) NSString * approve;

+ (instancetype)sharedInstance;


@end
