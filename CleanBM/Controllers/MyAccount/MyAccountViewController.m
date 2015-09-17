//
//  MyAccountViewController.m
//  CleanBM
//
//  Created by Developer on 16/09/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "MyAccountViewController.h"
#import <Parse/Parse.h>

@interface MyAccountViewController ()
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
}

@end
