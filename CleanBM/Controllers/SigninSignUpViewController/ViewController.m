//
//  ViewController.m
//  CleanBM
//
//  Created by Developer on 16/07/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "ViewController.h"
#import "Constant.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "SignUpViewController.h"
#import "StringUtilityClass.h"
#import <Parse/Parse.h>
#import "CleanBMLoader.h"
#import "AppDelegate.h"
#import "NearMeViewController.h"

@interface ViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *lblSignIn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswod;
@property (weak, nonatomic) IBOutlet UIImageView *imgCheckRemember;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UILabel *lblFacebookLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *viewSkipButton;

@end

@implementation ViewController

#pragma mark--
#pragma mark--VIEW LIFE CYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
        _lblFacebookLogin.font = [UIFont systemFontOfSize:20];
        _btnLogin.titleLabel.font =[UIFont systemFontOfSize:22];
        _txtEmailAddress.font = [UIFont systemFontOfSize:20];
        _txtPasswod.font = [UIFont systemFontOfSize:20];
        _lblSignIn.font = [UIFont systemFontOfSize:22];
    }else{
        _lblFacebookLogin.font = [UIFont systemFontOfSize:17];
        _btnLogin.titleLabel.font =[UIFont systemFontOfSize:17];
        _txtEmailAddress.font = [UIFont systemFontOfSize:17];
        _txtPasswod.font = [UIFont systemFontOfSize:17];
        _lblSignIn.font = [UIFont systemFontOfSize:18];
    }
    
    //Back button hide or show
    AppDelegate *appDelegate = [AppDelegate getInstance];
    if([appDelegate.strRootOrLogin isEqualToString:@"RootViewController"]){
        _btnBack.hidden = YES;
        _viewSkipButton.hidden = NO;
    }else{
        _btnBack.hidden = NO;
        _viewSkipButton.hidden = YES;
    }
    
    PFUser *currentUser = [PFUser currentUser];
    
    BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
    
    if(linkedWithFacebook || [[currentUser objectForKey:@"emailVerified"] boolValue]){
            // do stuff with the user
            NearMeViewController *nearMeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"nearMeViewController"];
            [self.navigationController pushViewController:nearMeViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    _txtEmailAddress.text = @"";
    _txtPasswod.text = @"";
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)actionLogin:(id)sender {
    
    if ([StringUtilityClass Trim:_txtEmailAddress.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Email Address."];
        return;
    }
    if (![StringUtilityClass validateEmail:_txtEmailAddress.text]) {
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Valid Email Address."];
        return;
    }
    if ([StringUtilityClass Trim:_txtPasswod.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter Password."];
        return;
    }
    if([StringUtilityClass Trim:_txtPasswod.text].length < 4){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Your password must be at least 4 characters long. Please try another."];
        return;
    }
    
    [self.view endEditing:YES];
    
    [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"email" equalTo:_txtEmailAddress.text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (objects.count > 0) {
            PFObject *object = [objects objectAtIndex:0];
            NSString *username = [object objectForKey:@"username"];
            [PFUser logInWithUsernameInBackground:username password:_txtPasswod.text block:^(PFUser* user, NSError* error){
                NSLog(@"User Info =%@",user);
                [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                if(user != nil){
                    // Do stuff after successful login.
                    if (![[user objectForKey:@"emailVerified"] boolValue]) {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Please check your mail to verify your e-mail for CleanBM.You are not verified right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You have Logged In successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag = 102;
                        [alert show];
                    }
                } else {
                    // The login failed. Check error to see why.
                    NSString *errorString = [error userInfo][@"error"];
                    
                    if([errorString isEqualToString:@"invalid login parameters"]){
                        // Show the errorString somewhere and let the user try again.
                        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"The email and password you entered don't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    }else{
                        // Show the errorString somewhere and let the user try again.
                        [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    }
                }
            }];
        }else{
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];

            [[[UIAlertView alloc]initWithTitle:@"Error" message:@"The email and password you entered don't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

- (IBAction)actionFacebookLogin:(id)sender {
    
    [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
    [PFFacebookUtils logInInBackgroundWithReadPermissions: @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"email", @"public_profile"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [self _loadDataWithPFUser:user];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self _loadDataWithPFUser:nil];
        }
    }];
}

//Load Facebook data after login with facebook
- (void)_loadDataWithPFUser:(PFUser *)user {
    
    //NSArray *permissions = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"email", @"public_profile"];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSLog(@"User Data = %@",userData);
            
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
            if(user != nil){
                user[@"name"] = userData[@"name"];
                user[@"userProfile"] = @"basic";

                [user saveInBackground];
            }
            
            AppDelegate *appDelegate = [AppDelegate getInstance];
            if([appDelegate.strRootOrLogin isEqualToString:@"RootViewController"]){
                NearMeViewController *nearMeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"nearMeViewController"];
                [self.navigationController pushViewController:nearMeViewController animated:YES];
            }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
        }
    }];
}

- (IBAction)actionSignUP:(id)sender {
    SignUpViewController *signUpViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"signUpViewController"];
    
    [self.navigationController pushViewController:signUpViewController animated:YES];
}
- (IBAction)actionForgotPassword:(id)sender {
    
    [self.view endEditing:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password?"
                                                    message:@"Please enter your email address."
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO Thanks",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
}

- (IBAction)actionSkipLogin:(id)sender {
    
    NearMeViewController *nearMeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"nearMeViewController"];
    [self.navigationController pushViewController:nearMeViewController animated:YES];
}

#pragma mark
#pragma mark-- UITEXTFIELD DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark--
#pragma mark--UIALERT VIEW DELEGATE
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 100:{
            switch (buttonIndex) {
                case 0:{
                    NSLog(@"%@", [alertView textFieldAtIndex:0].text);
                    
                    if ([StringUtilityClass Trim:[alertView textFieldAtIndex:0].text].length == 0){
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter Email Address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        alert.tag = 101;
                        [alert show];
                        
                        return;
                    }
                    if (![StringUtilityClass validateEmail:[alertView textFieldAtIndex:0].text]) {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter Valid Email Address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        alert.tag = 101;
                        [alert show];
                        return;
                    }
                    
                    [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];

                    [PFUser requestPasswordResetForEmailInBackground:[alertView textFieldAtIndex:0].text block:^(BOOL succeeded, NSError *error) {
                        NSLog(@"Request for Password Reset");
                        
                        [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];

                        if(!succeeded){
                            //Error
                            NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                            [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        }else{
                            
                            //Please follow the instructions we sent to yogendra.solanki@ratufa.com
                            NSString *strMessage = [NSString stringWithFormat:@"Please follow the instructions we sent to %@.",[alertView textFieldAtIndex:0].text];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:strMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 101:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password?"
                                                            message:@"Please enter your email address."
                                                           delegate:self
                                                  cancelButtonTitle:@"YES"
                                                  otherButtonTitles:@"NO Thanks",nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = 100;
            [alert show];
        }
            break;
        case 102:{
            AppDelegate *appDelegate = [AppDelegate getInstance];
            if([appDelegate.strRootOrLogin isEqualToString:@"RootViewController"]){
                NearMeViewController *nearMeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"nearMeViewController"];
                [self.navigationController pushViewController:nearMeViewController animated:YES];
            }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
        }
            break;
        default:
            break;
    }
}

#pragma mark--ACTION BACK
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
