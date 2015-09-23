//
//  SupportViewController.m
//  CleanBM
//
//  Created by Developer on 06/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "SupportViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "NearMeViewController.h"
#import "SearchLocationViewController.h"
#import "AddLoacationViewController.h"
#import "ViewController.h"
#import "MyAccountViewController.h"
#import "AppDelegate.h"

@interface SupportViewController ()<UIWebViewDelegate,MFMailComposeViewControllerDelegate,REMenuDelegate,UIAlertViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIWebView *webViewSupport;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIVewController;
@property (weak, nonatomic) IBOutlet UIButton *btnSupport;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;

@end

@implementation SupportViewController

#pragma mark-- VIEW LIFE CYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Webview Load URL
   // NSString *strUrl = @"http://www.cleanbm.com/support";
    //[_activityIVewController startAnimating];
    //[_webViewSupport loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]]];
    
    [self configureMenuView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark-- ACTION BACK
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma MENU BUTTON
-(IBAction)actionMenuButton:(id)sender{

    [self menuButton];
    
}

- (void) menuButton{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
}



-(void)configureMenuView{
    
    // do stuff with the user
    REMenuItem *loginSignUpItem = [[REMenuItem alloc] initWithTitle:@"Home"
                                                           subtitle:@""
                                                              image:[UIImage imageNamed:@"home_icon"]
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 NSLog(@"Item: %@", item);
                                                                 
                                                                 [self performSelector:@selector(actionNearMe:) withObject:nil afterDelay:0.3];
                                                             }];
    
    
    REMenuItem *searchNearMeItem = [[REMenuItem alloc] initWithTitle:@"Search Near Me"
                                                            subtitle:@""
                                                               image:[UIImage imageNamed:@"location_icon"]
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  NSLog(@"Item: %@", item);
                                                                  
                                                                  [self performSelector:@selector(actionHomePage:) withObject:nil afterDelay:0.3];
                                                                  
                                                              }];
    
    REMenuItem *searchLocationItem = [[REMenuItem alloc] initWithTitle:@"Search Location"
                                                              subtitle:@""
                                                                 image:[UIImage imageNamed:@"search_icon"]
                                                      highlightedImage:nil
                                                                action:^(REMenuItem *item) {
                                                                    NSLog(@"Item: %@", item);
                                                                    
                                                                    [self performSelector:@selector(actionSearchNearMe:) withObject:nil afterDelay:0.3];
                                                                }];
    REMenuItem *addNewLocationItem = [[REMenuItem alloc] initWithTitle:@"Add New Location"
                                                                 image:[UIImage imageNamed:@"add_bathroom_icon"]
                                                      highlightedImage:nil
                                                                action:^(REMenuItem *item) {
                                                                    NSLog(@"Item: %@", item);
                                                                    
                                                                    [self performSelector:@selector(actionAddNewLocation:) withObject:nil afterDelay:0.3];
                                                                }];
    
    REMenuItem *supportItem = [[REMenuItem alloc] initWithTitle:@"Support"
                                                          image:[UIImage imageNamed:@"support_icon"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             
                                                            // [self performSelector:@selector(actionSupportCleanBM:) withObject:nil afterDelay:0.3];
                                                         }];
    
    REMenuItem *logoutItem = [[REMenuItem alloc] initWithTitle:@"Login/Sign Up"
                                                      subtitle:@""
                                                         image:[UIImage imageNamed:@"login_icon"]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            NSLog(@"Item: %@", item);
                                                            
                                                            [self performSelector:@selector(actionLoginSignUp:) withObject:nil afterDelay:0.3];
                                                        }];
    
    REMenuItem *myAccountItem =[[REMenuItem alloc] initWithTitle:@"My Account"
                                                        subtitle:@""
                                                           image:[UIImage imageNamed:@"login_icon"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                              
                                                              [self performSelector:@selector(actionMyAccount:) withObject:nil afterDelay:0.3];
                                                          }];
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        // do stuff with the user
        
        logoutItem = [[REMenuItem alloc] initWithTitle:@"Log Out"
                                              subtitle:@""
                                                 image:[UIImage imageNamed:@"sing_out_button"]
                                      highlightedImage:nil
                                                action:^(REMenuItem *item) {
                                                    NSLog(@"Item: %@", item);
                                                    
                                                    [self performSelector:@selector(actionLogout:) withObject:nil afterDelay:0.1];
                                                }];
        
        loginSignUpItem.tag = 0;
        searchNearMeItem.tag = 1;
        searchLocationItem.tag = 2;
        addNewLocationItem.tag = 3;
        supportItem.tag = 4;
        logoutItem.tag = 6;
        myAccountItem.tag = 5;
        
        _menu = [[REMenu alloc] initWithItems:@[loginSignUpItem, searchNearMeItem, searchLocationItem, addNewLocationItem,supportItem,myAccountItem ,logoutItem]];
        
    }else{
        loginSignUpItem.tag = 0;
        searchNearMeItem.tag = 1;
        searchLocationItem.tag = 2;
        addNewLocationItem.tag = 3;
        supportItem.tag = 4;
        logoutItem.tag = 5;
        _menu = [[REMenu alloc] initWithItems:@[loginSignUpItem, searchNearMeItem, searchLocationItem, addNewLocationItem,supportItem,logoutItem]];
    }
    
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    self.menu.delegate = self;
    
    [self.menu setClosePreparationBlock:^{
        NSLog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        NSLog(@"Menu did close");
    }];
}

-(IBAction)actionHomePage:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    BOOL isHomeAvailabel = NO;

    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[HomeViewController class]])
        {
            isHomeAvailabel = YES;
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    if(!isHomeAvailabel){
        AppDelegate *appDelegate = [AppDelegate getInstance];
        appDelegate.strRequestFor = @"NearMe";
        HomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
        [self.navigationController pushViewController:homeViewController animated:YES];
    }
}

#pragma ACTION LOGIN SIGNUP AFTER DELAY
-(IBAction)actionLoginSignUp:(id)sender{
    
    ViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
    
    AppDelegate *appDelegate = [AppDelegate getInstance];
    appDelegate.strRootOrLogin = @"LoginViewController";
    
    [self.navigationController pushViewController:viewController animated:YES];
}


-(IBAction)actionNearMe:(id)sender{
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[NearMeViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}


-(IBAction)actionLogout:(id)sender{
    
    NSLog(@"Logout");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Do you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil ];
    
    alert.tag = 123;
    [alert show];
}

#pragma ACTION SEARCH NEAR ME AFTER DELAY
-(IBAction)actionSearchNearMe:(id)sender{
    
    
    NSArray *viewControllers = [self.navigationController viewControllers];

    BOOL isSearchAvailabel = NO;
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[SearchLocationViewController class]])
        {
            isSearchAvailabel = YES;
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    if(!isSearchAvailabel){
        SearchLocationViewController *searchLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"searchLocationViewController"];
        [self.navigationController pushViewController:searchLocationViewController animated:YES];
    }
}

#pragma ACTION SUPPORT CLEANBM AFTER DELAY
-(IBAction)actionAddNewLocation:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    BOOL isAddLocationAvailabel = NO;
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[AddLoacationViewController class]])
        {
            isAddLocationAvailabel = YES;
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    if(!isAddLocationAvailabel){
        AddLoacationViewController *addLoacationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addLoacationViewController"];
        [self.navigationController pushViewController:addLoacationViewController animated:YES];
    }
}

-(IBAction)actionMyAccount:(id)sender{
    MyAccountViewController *myAccountViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"myAccountViewController"];
    [self.navigationController pushViewController:myAccountViewController animated:YES];
}


#pragma mark - REMenu Delegate Methods
-(void)willOpenMenu:(REMenu *)menu{
    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

-(void)didOpenMenu:(REMenu *)menu{
    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

-(void)willCloseMenu:(REMenu *)menu{
    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

-(void)didCloseMenu:(REMenu *)menu{
    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}


#pragma mark--WEBVIEW DELEGATE
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //[_activityIVewController stopAnimating];
    //_activityIVewController.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    //[_activityIVewController stopAnimating];
   // _activityIVewController.hidden = YES;
}

-(IBAction)actionSupportLink:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.cleanbm.com/support"]];
}

-(IBAction)actionEmail:(id)sender{
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"CleanBM Support"];
    //[controller setMessageBody:@"Hello there." isHTML:NO];
    
    [controller setToRecipients:@[@"attendant@cleanbm.com"]];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark-- MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark-- UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 123:
            if(buttonIndex == 1)
            {
                [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                    if(error == nil){
                        [self configureMenuView];
                    }
                }];
            }
            break;
        default:
            break;
    }
}


@end
