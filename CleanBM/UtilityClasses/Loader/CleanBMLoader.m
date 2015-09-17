//
//  CleanBMLoader.m
//  CleanBM
//
//  Created by Developer on 05/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "CleanBMLoader.h"
#import "AppDelegate.h"


@implementation CleanBMLoader



+(void)showLoader:(UIViewController *)viewController withShowHideOption:(BOOL)isShow{
    //isShowHide is yes = show loader  and NO = hide loader
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UIView *viewLoader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height)];
    
    viewLoader.tag = 12345678;
    
    viewLoader.backgroundColor = [UIColor clearColor];
    
    UIView *viewTranspentent = [[UIView alloc]initWithFrame:CGRectMake(0, 0, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height)];
    viewTranspentent.backgroundColor = [UIColor blackColor];
    
    viewTranspentent.alpha = 0.2;
    
    UIImageView *imgLoader = [[UIImageView alloc]initWithFrame:CGRectMake((viewLoader.frame.size.width/2) - (80/2),(viewLoader.frame.size.height / 2) - (80 / 2),80,80)];
    
    [imgLoader setImage:[UIImage imageNamed:@"button_plan"]];
    
    UIImageView *imgLoaderArrow = [[UIImageView alloc]initWithFrame:CGRectMake((viewLoader.frame.size.width/2) - (92/2),(viewLoader.frame.size.height / 2) - (92 / 2),92,92)];
    
    [imgLoaderArrow setImage:[UIImage imageNamed:@"loader_blue1"]];
    
    UIImageView *imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake((viewLoader.frame.size.width/2) - (50/2),(viewLoader.frame.size.height / 2) - (30 / 2)- 5,50,30)];
    
    [imgLogo setImage:[UIImage imageNamed:@"logo_withTitle"]];
    
    [viewLoader addSubview:viewTranspentent];
    [viewLoader addSubview:imgLoaderArrow];
    [viewLoader addSubview:imgLoader];
    [viewLoader addSubview:imgLogo];

    //SpinAnimationOnImageView
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * 1 * 0.5 ];
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1500;
    [imgLoaderArrow.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    if(isShow){
        //Show loader
        [appDelegate.window addSubview:viewLoader];
    }else{
        // Hide Loader
        NSArray *subviews = [appDelegate.window subviews];
        for (UIView *subview in subviews){
            @autoreleasepool{
                if (subview.tag == 12345678){
                    [subview removeFromSuperview];
                }
            }
        }
    }
}

@end
