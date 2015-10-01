//
//  SignUpViewController.m
//  CleanBM
//
//  Created by Developer on 29/07/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "StringUtilityClass.h"
#import "CleanBMLoader.h"


@interface SignUpViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtpassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@end

@implementation SignUpViewController


#pragma mark

#pragma mark-- VIEW LIFE CYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark
#pragma mark-- ACTION METHODS
- (IBAction)actionBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSignUp:(id)sender {
    
    if ([StringUtilityClass Trim:_txtName.text].length == 0){
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
    if([StringUtilityClass Trim:_txtpassword.text].length < 4)
    {
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Your password must be at least 4 characters long. Please try another."];
        return;
    }
    if ([StringUtilityClass Trim:_txtpassword.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Password."];
        return;
    }
    if ([StringUtilityClass Trim:_txtConfirmPassword.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Confirm Password."];
        return;
    }
    if(![_txtpassword.text isEqualToString:_txtConfirmPassword.text])
    {
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"These passwords don't match. Try again?"];
        return;
    }
    
    [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
    
    // Sign up using Parse
    PFUser *user = [PFUser user];
    user.username = _txtEmailAddress.text;
    user.password =_txtpassword.text;
    user.email = _txtEmailAddress.text;
    
    user[@"name"] = _txtName.text;
    user[@"userProfile"] = @"basic";

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
        
        if (!error) {
            // Hooray! Let them use the app now.
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Please check your mail to verify your e-mail for CleanBM." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alertView.tag = 100;
            [alertView show];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

#pragma mark
#pragma mark-- UITEXTFIELD DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark-- UIALERTVIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 100:{
            //Email Verification alert
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}
@end
