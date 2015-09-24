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

@protocol BathRoomDetailProtocolDelegate <NSObject>
@optional
- (void) processCompleted;
@end


@interface BathRoomDetailViewController : UIViewController
{
    // Delegate to respond back
    id <BathRoomDetailProtocolDelegate> _delegate;
}
@property(nonatomic ,strong)PFObject *bathRoomDetail;

@property (strong, readonly, nonatomic) REMenu *menu;

@property (nonatomic,strong) id delegate;

@property(nonatomic, strong) NSMutableArray *mArrayBathRoomImages;


-(void)startSampleProcess;

@end
