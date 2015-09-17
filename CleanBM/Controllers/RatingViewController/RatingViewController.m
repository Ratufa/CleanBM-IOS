//
//  RatingViewController.m
//  CleanBM
//
//  Created by Developer on 18/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "RatingViewController.h"
#import "TPFloatRatingView.h"
#import "StringUtilityClass.h"
#import <Parse/Parse.h>
#import "CleanBMLoader.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface RatingViewController ()<TPFloatRatingViewDelegate,UIAlertViewDelegate>
{
    CGFloat bathroomRating;
    NSString *strBathRoomType;
    PFObject *reviewObject;
    BOOL isGivenRating;
}

@property (weak, nonatomic) IBOutlet TPFloatRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UIButton *btnSquat;
@property (weak, nonatomic) IBOutlet UIButton *btnSit;
@property (weak, nonatomic) IBOutlet UITextView *txtReviewMessage;

@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ratingView.delegate = self;
    _ratingView.emptySelectedImage = [UIImage imageNamed:@"unselected_rating"];
    _ratingView.fullSelectedImage = [UIImage imageNamed:@"selected_rating"];
    _ratingView.contentMode = UIViewContentModeScaleAspectFill;
    _ratingView.maxRating = 5;
    _ratingView.minRating = 0;
    _ratingView.rating = 0.0;
    _ratingView.editable = YES;
    _ratingView.halfRatings = NO;
    _ratingView.floatRatings = YES;
    
    isGivenRating = NO;
    
    PFUser *currentUser = [PFUser currentUser];
    
    for (PFObject *pfObject in _mArrayReviewsList) {
        
        if(currentUser){
            if([currentUser.objectId isEqualToString:pfObject[@"userId"]] && [_strBathRoomId isEqualToString:pfObject[@"bathRoomID"]]){
                reviewObject = pfObject;
                
                isGivenRating = YES;
                
                _ratingView.rating = [pfObject[@"bathRating"]floatValue];
                
                if([pfObject[@"bathRoomType"] isEqualToString:@"Squat"]){
                    //Squat Bathroom
                    [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
                    [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
                    strBathRoomType = @"Squat";
                }else{
                    //Sit Bathroom
                    [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
                    [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
                    strBathRoomType = @"Sit";
                }
                _txtReviewMessage.text = pfObject[@"MessageReview"];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSubmitReview:(id)sender {
    
    if ([StringUtilityClass Trim:strBathRoomType].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please select bathroom type Squat/Sit."];
        return;
    }
    if ([StringUtilityClass Trim:_txtReviewMessage.text].length == 0) {
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter your Comment."];
        return;
    }
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        // do stuff with the user
        
        if(isGivenRating){
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
            PFQuery *query = [PFQuery queryWithClassName:@"RattingByUser"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:reviewObject.objectId
                                         block:^(PFObject *review, NSError *error) {
                                             // Now let's update it with some new data. In this case, only cheatMode and score
                                             review[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
                                             review[@"MessageReview"] = _txtReviewMessage.text;
                                             review[@"bathRoomType"] = strBathRoomType;
                                             
                                             [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                 if(succeeded){
                                                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                     alert.tag = 888;
                                                     [alert show];
                                                 }else{                                                      NSString *errorString = [error userInfo][@"error"];
                                                     // Show the errorString somewhere and let the user try again.
                                                     [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                                 }
                                                 [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                                             }];
                                         }];
        }
        else{
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
            
            PFObject* bathtoomRating = [PFObject objectWithClassName:@"RattingByUser"];
            bathtoomRating[@"userId"] = currentUser.objectId;
            bathtoomRating[@"userName"] = currentUser[@"name"];
            bathtoomRating[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
            bathtoomRating[@"MessageReview"] = _txtReviewMessage.text;
            bathtoomRating[@"bathRoomType"] = strBathRoomType;
            bathtoomRating[@"bathRoomID"] = _strBathRoomId;
            
            [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.tag = 888;
                    [alert show];
                }else{
                    NSString *errorString = [error userInfo][@"error"];
                    // Show the errorString somewhere and let the user try again.
                    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
                [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
            }];
        }
    } else {
        // show the signup or login screen
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
        
        alert.tag = 123;
        
        [alert show];
        
        return;
    }

}

#pragma mark RatingView delegate
- (void)floatRatingView:(TPFloatRatingView *)ratingView ratingDidChange:(CGFloat)rating{
    NSLog(@"rate value = %f", rating);
    bathroomRating = rating;
}

- (void)floatRatingView:(TPFloatRatingView *)ratingView continuousRating:(CGFloat)rating{
    NSLog(@"rate value = %f", rating);
    bathroomRating = rating;
}

- (IBAction)actionBathroomType:(id)sender {
    switch ([sender tag]) {
        case 111:{
            //Squat Bathroom
            [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
            [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
            strBathRoomType = @"Squat";
        }
            break;
        case 222:{
            //Sit Bathroom
            [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
            [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
            strBathRoomType = @"Sit";
        }
            break;
        default:
            break;
    }
}

#pragma mark-- UIALERT VIEW DELEGATE

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case 888:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 123:{
            if(buttonIndex == 0){
                ViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
                AppDelegate *appDelegate = [AppDelegate getInstance];
                appDelegate.strRootOrLogin = @"LoginViewController";
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
        default:
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
