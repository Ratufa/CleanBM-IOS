//
//  AddLoacationViewController.m
//  CleanBM
//
//  Created by Developer on 19/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "AddLoacationViewController.h"
#import <MapKit/MapKit.h>
#import "AddNewLocationViewController.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "NearMeViewController.h"
#import "SearchLocationViewController.h"
#import "ViewController.h"
#import "MyAccountViewController.h"
#import "AppDelegate.h"
#import "SupportViewController.h"

@interface AddLoacationViewController ()<MKMapViewDelegate,REMenuDelegate,UIAlertViewDelegate>{
    
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AddLoacationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView.delegate = self;
    
    [self setposition];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self configureMenuView];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)actionGoToHome:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionAddThisLocation:(id)sender {
    AddNewLocationViewController *addNewLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNewLocationViewController"];
    addNewLocationViewController.strRequestFor = @"addLocation";
    addNewLocationViewController.requestFor = 1;
    [self.navigationController pushViewController:addNewLocationViewController animated:YES];
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

#pragma ACTION SUPPORT CLEANBM AFTER DELAY
-(IBAction)actionSupportCleanBM:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    BOOL isSupportAvailabel = NO;
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[SupportViewController class]])
        {
            isSupportAvailabel = YES;
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    if(!isSupportAvailabel){
        SupportViewController *supportViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"supportViewController"];
        [self.navigationController pushViewController:supportViewController animated:YES];
    }
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
    
    alert.tag = 333;
    [alert show];
}

#pragma ACTION SEARCH NEAR ME AFTER DELAY
-(IBAction)actionSearchNearMe:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    BOOL isSearchLocationAvailabel = NO;
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[SearchLocationViewController class]])
        {
            isSearchLocationAvailabel = YES;
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    if(!isSearchLocationAvailabel){
        SearchLocationViewController *searchLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"searchLocationViewController"];
        [self.navigationController pushViewController:searchLocationViewController animated:YES];

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


#pragma mark-- MAPVIEW DELEGATE

#pragma mark - MKMapView Delegate.

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation{
    self.mapView.centerCoordinate = userLocation.location.coordinate;
    //[self setposition];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%.8f",location.coordinate.longitude] forKey:@"AddLocationLongitude"];
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%.8f",location.coordinate.latitude] forKey:@"AddLocationLatitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *arrayLocation = [self getAddressFromLatLon:location.coordinate.latitude withLongitude:location.coordinate.longitude];
    
    if([arrayLocation count] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"NewLocationFullAddress"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else{
        NSString *strAddress = [NSString stringWithFormat:@"%@",[arrayLocation[0] valueForKey:@"formatted_address"]];
        
        strAddress = [strAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        NSArray *arrayAdd = [strAddress componentsSeparatedByString:@","];
        
        strAddress = [NSString stringWithFormat:@"%@,%@",arrayAdd[0],arrayAdd[1]];
        
        [[NSUserDefaults standardUserDefaults] setValue:strAddress forKey:@"NewLocationFullAddress"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(NSArray *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude{
    NSError *error = nil;
    
    NSString *lookUpString  = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&amp;sensor=false", pdblLatitude,pdblLongitude];
    
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:lookUpString]];
    
    if(jsonResponse == nil){
        
        NSArray *aaray = [[NSArray alloc] init];
        return aaray;
    }
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonResponse options:kNilOptions error:&error];
    
    NSArray* jsonResults = [jsonDict objectForKey:@"results"];
    
    return jsonResults;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]init];
    annotationView.canShowCallout = NO;
    return annotationView;
}

- (void)setposition{
    
    CLLocationCoordinate2D location;
    location.latitude = [[[NSUserDefaults standardUserDefaults]valueForKey:@"latitude"]doubleValue];
    location.longitude = [[[NSUserDefaults standardUserDefaults]valueForKey:@"longitude"]doubleValue];

    //SHOW USER LOCATION
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.5;
    span.longitudeDelta = 0.5;
    region.span = span;
    region.center = location;
    region = MKCoordinateRegionMakeWithDistance(location,MilesToMeters(5),MilesToMeters(5));
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
}

#pragma mark -- GET LATITUDE AND LONGITUDE FROM ADDRESS
-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    //NSLog(@"View Controller get Location Logitute : %f",center.latitude);
    //NSLog(@"View Controller get Location Latitute : %f",center.longitude);
    return center;
}

#pragma mark --  MILES TO METERS
float MilesToMeters(float miles){
    // 1 mile is 1609.344 meters
    // source: http://www.google.com/search?q=1+mile+in+meters
    return 1609.344f * miles;
}

#pragma mark -- METERS TO MILES
float MetersToMiles(float meters){
    return meters / 1609.344f;
}


#pragma mark-- UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 333:{
            if(buttonIndex == 1){
                //Logout
                [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                    if(error == nil){
                        [self configureMenuView];
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
