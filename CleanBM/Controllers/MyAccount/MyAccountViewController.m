//
//  MyAccountViewController.m
//  CleanBM
//
//  Created by Developer on 16/09/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "MyAccountViewController.h"
#import <Parse/Parse.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "StringUtilityClass.h"


@interface MyAccountViewController ()<UIAlertViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblMyAccount;

@end

@implementation MyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *currentUser = [PFUser currentUser];
    
    BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
    if(linkedWithFacebook){
        _txtEmailAddress.userInteractionEnabled = _txtPassword.userInteractionEnabled = _txtConfirmPassword.userInteractionEnabled = NO;
    }else{
        _txtEmailAddress.userInteractionEnabled = _txtPassword.userInteractionEnabled = _txtConfirmPassword.userInteractionEnabled = YES;
    }
    _txtName.text = currentUser[@"name"];
    _txtEmailAddress.text = currentUser[@"email"];
    _txtPassword.text = _txtConfirmPassword.text = currentUser.password;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionUpgradeMyAccount:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Would you like to upgrade to Premium?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    
    alert.tag = 222;
    [alert show];
}

#pragma mark-- SAVE CHANGES
- (IBAction)actionSaveChanges:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    
    BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
    
    if(linkedWithFacebook){
        //User login with facebook
        if([StringUtilityClass Trim:_txtName.text].length == 0){
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Name."];
            return;
        }
        //Putting data
        currentUser[@"name"] = _txtName.text;
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                //profile updated success fully
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Profile Updated successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag = 111;
                [alert show];
                
            }else{
                //Error
                NSString *strError = [error userInfo][@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
        
    }else{
        //Normal User login
        if([StringUtilityClass Trim:_txtName.text].length == 0){
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Name."];
            return;
        }
        if ([StringUtilityClass Trim:_txtEmailAddress.text].length == 0){
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Email Address."];
            return;
        }
        if (![StringUtilityClass validateEmail:_txtEmailAddress.text]) {
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Valid Email Address."];
            return;
        }
        
        if ([StringUtilityClass Trim:_txtPassword.text].length == 0){
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Password."];
            return;
        }
        if([StringUtilityClass Trim:_txtPassword.text].length < 4){
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Your password must be at least 4 characters long. Please try another."];
            return;
        }
        
        //Putting data
        currentUser[@"name"] = _txtName.text;
        currentUser.username = _txtEmailAddress.text;
        currentUser.password = _txtPassword.text;
        currentUser.email = _txtEmailAddress.text;
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                //profile updated success fully
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Profile Updated successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag = 111;
                [alert show];
                
            }else{
                //Error
                
                NSString *strError = [error userInfo][@"error"];
                if([strError isEqualToString:[NSString stringWithFormat:@"username %@ already taken",_txtEmailAddress.text]]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Email address already taken!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }];
    }
}

#pragma mark-- UIALERT VIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case 111:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 222:{
            
            if (buttonIndex == 0) {
                
            
            PFUser *currentUser = [PFUser currentUser];
            
            //Putting data
            currentUser[@"userProfile"] = @"premium";
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    //profile updated success fully
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Profile Updated successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alert.tag = 111;
                    [alert show];
                    
                }else{
                    //Error
                    NSString *strError = [error userInfo][@"error"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                }
            }];
                }
            
        }
            break;
        default:
            break;
    }
}

@end
