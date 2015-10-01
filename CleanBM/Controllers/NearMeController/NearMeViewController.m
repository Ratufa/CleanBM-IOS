//
//  NearMeViewController.m
//  CleanBM
//
//  Created by Developer on 04/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "NearMeViewController.h"
#import "Constant.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "StringUtilityClass.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "ViewController.h"
#import "SearchLocationViewController.h"
#import "AddLoacationViewController.h"
#import "SupportViewController.h"
#import "MyAccountViewController.h"
#import "AFNetworking.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>


@interface NearMeViewController ()<UITextFieldDelegate,REMenuDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSString *strReferenceKey;
}
@property (weak, nonatomic) IBOutlet UITextField *txtFieldAddressLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPushForNear;
@property (weak, nonatomic) IBOutlet UILabel *lblResultsText;
@property (weak, nonatomic) IBOutlet UILabel *lblAdvanceSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnLookUpLocation;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scroolViewContent;


//Google place api 
@property NSMutableArray *localSearchQueries;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLocation;
@property NSMutableArray *pastSearchWords;
@property NSMutableArray *pastSearchResults;
@property NSTimer *autoCompleteTimer;
@property NSString *substring;
@property CLLocationManager *locationManager;


@end

NSString *const apiKey = @"AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE";

@implementation NearMeViewController

#pragma mark-- VIEW LIFE CYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Set Font Size according to Screen size
    if (IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
        _lblPushForNear.font = [UIFont systemFontOfSize:21];
        _btnLookUpLocation.titleLabel.font =[UIFont systemFontOfSize:20];
        _lblResultsText.font = [UIFont systemFontOfSize:14.5];
        _lblAdvanceSearch.font = [UIFont systemFontOfSize:20];
        _txtFieldAddressLocation.font = [UIFont systemFontOfSize:21];
        
    }else{
        _lblPushForNear.font = [UIFont systemFontOfSize:16];
        _btnLookUpLocation.titleLabel.font =[UIFont systemFontOfSize:16];
        _lblResultsText.font = [UIFont systemFontOfSize:11];
        _lblAdvanceSearch.font = [UIFont systemFontOfSize:17];
        _txtFieldAddressLocation.font = [UIFont systemFontOfSize:17];
    }
    
    //ScrollView will enabled for iPhone 4
    if(IS_IPHONE_4)
    {
        _scroolViewContent.scrollEnabled = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    //Configure Menu View
    [self configureMenuView];
    
    _txtFieldAddressLocation.text = @"";
    
    self.localSearchQueries = [NSMutableArray array];
    self.pastSearchWords = [NSMutableArray array];
    self.pastSearchResults = [NSMutableArray array];
    
    _tableViewLocation.hidden = YES;
    
    strReferenceKey= @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)configureMenuView{
    
    // do stuff with the user
    REMenuItem *loginSignUpItem = [[REMenuItem alloc] initWithTitle:@"Home"
                                                           subtitle:@""
                                                              image:[UIImage imageNamed:@"home_icon"]
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 NSLog(@"Item: %@", item);
                                                                 
                                                                 //[self performSelector:@selector(actionHomePage:) withObject:nil afterDelay:0.3];
                                                             }];
    
    
    REMenuItem *searchNearMeItem = [[REMenuItem alloc] initWithTitle:@"Search Near Me"
                                                            subtitle:@""
                                                               image:[UIImage imageNamed:@"location_icon"]
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  NSLog(@"Item: %@", item);
                                                                  
                                                                  [self performSelector:@selector(actionNearMe:) withObject:nil afterDelay:0.3];
                                                                  
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
                                                             
                                                             [self performSelector:@selector(actionSupportCleanBM:) withObject:nil afterDelay:0.3];
                                                             
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
    
    BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
    
    if(linkedWithFacebook || [[currentUser objectForKey:@"emailVerified"] boolValue]){
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

#pragma mark--UITEXTFIELD DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
//    NSString *searchWordProtection = [_txtFieldAddressLocation.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"Length: %lu",(unsigned long)searchWordProtection.length);
//    
//    if (searchWordProtection.length != 0) {
//        
//        [self runScript];
//        
//    } else {
//        NSLog(@"The searcTextField is empty.");
//    }
    
    
    self.substring = [NSString stringWithString:_txtFieldAddressLocation.text];
    self.substring= [self.substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    self.substring = [self.substring stringByReplacingCharactersInRange:range withString:string];
    
    if ([self.substring hasPrefix:@"+"] && self.substring.length >1) {
        self.substring  = [self.substring substringFromIndex:1];
        NSLog(@"This string: %@ had a space at the begining.",self.substring);
    }
    
    if (self.substring.length != 0) {
        
        _tableViewLocation.hidden = NO;
        
        [self runScript];
    }else{
        _tableViewLocation.hidden = YES;
    }
    
    return YES;
}

- (void)runScript{
    
    [self.autoCompleteTimer invalidate];
    self.autoCompleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.65f
                                                              target:self
                                                            selector:@selector(searchAutocompleteLocationsWithSubstring:)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)searchAutocompleteLocationsWithSubstring:(NSString *)substring
{
    [self.localSearchQueries removeAllObjects];
    [_tableViewLocation reloadData];
    
    if (![self.pastSearchWords containsObject:self.substring]) {
        [self.pastSearchWords addObject:self.substring];
        NSLog(@"Search: %lu",(unsigned long)self.pastSearchResults.count);
        [self retrieveGooglePlaceInformation:self.substring withCompletion:^(NSArray * results) {
            
            if(results.count > 0){
                if([[results objectAtIndex:0] isKindOfClass:[NSString class]]){
                    _tableViewLocation.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Please Check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    [self.localSearchQueries addObjectsFromArray:results];
                    NSDictionary *searchResult = @{@"keyword":self.substring,@"results":results};
                    [self.pastSearchResults addObject:searchResult];
                    [_tableViewLocation reloadData];
                }
            }else{
                _tableViewLocation.hidden = YES;
                
                UIAlertView *alert = [[UIAlertView  alloc]initWithTitle:@"CleanBM" message:@"Unable to find this location.Please modified your location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }
            
        }];
    }else {
        for (NSDictionary *pastResult in self.pastSearchResults) {
            if([[pastResult objectForKey:@"keyword"] isEqualToString:self.substring]){
                [self.localSearchQueries addObjectsFromArray:[pastResult objectForKey:@"results"]];
                [_tableViewLocation reloadData];
            }
        }
    }
}

#pragma mark - Google API Requests

-(void)retrieveGooglePlaceInformation:(NSString *)searchWord withCompletion:(void (^)(NSArray *))complete{
    NSString *searchWordProtection = [searchWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (searchWordProtection.length != 0) {
        
        CLLocation *userLocation = self.locationManager.location;
        NSString *currentLatitude = @(userLocation.coordinate.latitude).stringValue;
        NSString *currentLongitude = @(userLocation.coordinate.longitude).stringValue;
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=500&language=en&key=%@",searchWord,currentLatitude,currentLongitude,apiKey];
        NSLog(@"AutoComplete URL: %@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *results = [jSONresult valueForKey:@"predictions"];
            
            if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
                if (!error){
                    NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                    NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                    complete(@[@"API Error", newError]);
                    return;
                }
                complete(@[@"Actual Error", error]);
                return;
            }else{
                complete(results);
            }
        }];
        
        [task resume];
    }
    
}

-(void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSArray *))complete {
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",place,apiKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"result"];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                complete(@[@"API Error", newError]);
                return;
            }
            complete(@[@"Actual Error", error]);
            return;
        }else{
            complete(results);
        }
    }];
    
    [task resume];
}


#pragma mark-- LOOK UP LOCATION
-(IBAction)actionLookUpLocation:(id)sender{

    [self.autoCompleteTimer invalidate];
    
    if ([StringUtilityClass Trim:_txtFieldAddressLocation.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"CleanBM" Message:@"Please enter Location."];
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate getInstance];
    
    appDelegate.strRequestFor = @"SearchLocation";
    
    [self.view endEditing:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=false&key=AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE",strReferenceKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSMutableDictionary *mDict = (NSMutableDictionary *)responseObject;
        
        HomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
        homeViewController.strSearchLocation = _txtFieldAddressLocation.text;
        
        homeViewController.latitude = [mDict[@"result"][@"geometry"][@"location"][@"lat"] doubleValue];
        homeViewController.longitude = [mDict[@"result"][@"geometry"][@"location"][@"lng"] doubleValue];

        [self.navigationController pushViewController:homeViewController animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(IBAction)actionNearMe:(id)sender{
    AppDelegate *appDelegate = [AppDelegate getInstance];
    appDelegate.strRequestFor = @"NearMe";
    HomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    [self.navigationController pushViewController:homeViewController animated:YES];
}

#pragma mark--ACTION BACK
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark--
#pragma MENU BUTTON
-(IBAction)actionMenuButton:(id)sender{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.strMenu = @"NearMeMenu";
    
    [self menuButton];
}

- (void) menuButton{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
}


#pragma mark-- UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 123:
            if(buttonIndex == 1)
            {
                [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                    if(error == nil)
                    {
                        [self configureMenuView];
                    }
                }];
            }
            break;
        default:
            break;
    }
}

#pragma ACTION LOGIN SIGNUP AFTER DELAY
-(IBAction)actionLoginSignUp:(id)sender{
    ViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
    
    AppDelegate *appDelegate = [AppDelegate getInstance];
    appDelegate.strRootOrLogin = @"LoginViewController";
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(IBAction)actionLogout:(id)sender{
    
    NSLog(@"Logout");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Do you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil ];
    
    alert.tag = 123;
    [alert show];
}

#pragma ACTION SEARCH NEAR ME AFTER DELAY
-(IBAction)actionSearchNearMe:(id)sender{
    SearchLocationViewController *searchLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"searchLocationViewController"];
    [self.navigationController pushViewController:searchLocationViewController animated:YES];
}

#pragma ACTION SUPPORT CLEANBM AFTER DELAY
-(IBAction)actionSupportCleanBM:(id)sender{
    SupportViewController *supportViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"supportViewController"];
    [self.navigationController pushViewController:supportViewController animated:YES];
}

#pragma ACTION SUPPORT CLEANBM AFTER DELAY
-(IBAction)actionAddNewLocation:(id)sender{
    AddLoacationViewController *addLoacationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addLoacationViewController"];
    [self.navigationController pushViewController:addLoacationViewController animated:YES];
}

-(IBAction)actionMyAccount:(id)sender{
    MyAccountViewController *myAccountViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"myAccountViewController"];
    
    [self.navigationController pushViewController:myAccountViewController animated:YES];
}

#pragma mark-- UITALBLEVIEW DELEGATE AND DATASOURCE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return self.localSearchQueries.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    
    NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];

    UILabel *lblTitle = (UILabel*)[cell viewWithTag:100];
    
    lblTitle.text = [searchResult[@"terms"] objectAtIndex:0][@"value"];

    UILabel *lblDetail = (UILabel*)[cell viewWithTag:200];
    lblDetail.text = searchResult[@"description"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
    _txtFieldAddressLocation.text = [searchResult[@"terms"] objectAtIndex:0][@"value"];

    strReferenceKey = searchResult[@"reference"];
    
    _tableViewLocation.hidden = YES;
}


@end
