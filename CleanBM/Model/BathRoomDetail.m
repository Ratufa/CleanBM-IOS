//
//  BathRoomDetail.m
//  CleanBM
//
//  Created by Developer on 15/09/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "BathRoomDetail.h"

@implementation BathRoomDetail

@synthesize bathFullAddress;
@synthesize objectId;
@synthesize bathLocation;
@synthesize bathRating;
@synthesize bathRoomType;
@synthesize userId;
@synthesize description;
@synthesize approve;

+ (instancetype)sharedInstance
{
    static BathRoomDetail *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BathRoomDetail alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


@end
