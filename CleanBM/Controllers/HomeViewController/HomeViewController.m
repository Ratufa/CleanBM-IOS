//
//  HomeViewController.m
//  CleanBM
//
//  Created by Developer on 03/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "HomeViewController.h"
#import "NavigationViewController.h"
#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "NearMeViewController.h"
#import "CleanBMLoader.h"
#import "SupportViewController.h"
#import "AddNewLocationViewController.h"
#import <Parse/Parse.h>
#import "BathRoomDetailViewController.h"
#import "AddLoacationViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "SearchLocationViewController.h"
#import "AFNetworking.h"
#import "MyAccountViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <GoogleMobileAds/GADBannerView.h>

@interface HomeViewController ()<REMenuDelegate,UITextFieldDelegate,MKMapViewDelegate,UIAlertViewDelegate,GADBannerViewDelegate>
{
    BOOL isShown;
    UIView *_cautionView;
    NSMutableArray *mArraybathRooms;
}

@property (weak, nonatomic) IBOutlet UITextField *txtSearchLocation;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;

@property (weak, nonatomic) IBOutlet GADBannerView *adBannerView;

@end

@implementation HomeViewController


#pragma mark-- VIEW LIFE CYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Configure Menu View
    [self configureMenuView];
    
    AppDelegate *appDelegate = [AppDelegate getInstance];
    
    if([appDelegate.strRequestFor isEqualToString:@"NearMe"]){
        
        [self addMarkersOnMapWithLatitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"latitude"] doubleValue] andLongitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"longitude"] doubleValue]];
        
        [self getAllBathRoomsWithLatitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"latitude"] doubleValue] andLongitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"longitude"] doubleValue]];
    }else{
        [self addMarkersOnMapWithLatitude:_latitude andLongitude:_longitude];
        
        [self getAllBathRoomsWithLatitude:_latitude andLongitude:_longitude];
    }
    
    //Google Ads
    _adBannerView.adUnitID = @"ca-app-pub-6582923366746091/1460886964";
    _adBannerView.rootViewController = self;
    _adBannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    NSString *strId = [[NSUserDefaults standardUserDefaults]valueForKey:@"DeviceId"];
    
    request.testDevices = @[strId];
    [_adBannerView loadRequest:request];
}

#pragma mark -- GET RESTAURANT'S
-(void)getRestaurantsWithLocationName:(NSString *)locationName{
    
    //CleanBM key = AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE
    
    // upeepz key = AIzaSyCuTCpdsXmh8pmVjXfis0Ta-dBBwHnwPIw
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+%@&key=AIzaSyCuTCpdsXmh8pmVjXfis0Ta-dBBwHnwPIw",locationName] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            NSArray *arrayRestaurant = [responseObject valueForKey:@"results"];
            
            NSInteger counter = mArraybathRooms.count;
            
            NSMutableArray *mArrayHolder = [mArraybathRooms mutableCopy];
            
            for (NSMutableDictionary *mDictRestaurantDetail in arrayRestaurant) {
                
                BOOL isLocationAvailable = NO;
                
                for (id object in mArrayHolder) {
                    
                    if([object isKindOfClass:[PFObject class]]){
                        
                        PFGeoPoint *bathroomGeoPoint = object[@"bathLocation"];
                        
                        NSDictionary *bathroomGeoLocation = [[mDictRestaurantDetail objectForKey:@"geometry"] objectForKey:@"location"];
                        
                        double latitude = [bathroomGeoLocation[@"lat"] doubleValue];
                        
                        double longitude = [bathroomGeoLocation[@"lng"] doubleValue];
                        
                        if(bathroomGeoPoint.latitude == latitude && bathroomGeoPoint.longitude == longitude){
                            
                            isLocationAvailable = YES;
                            break;
                        }
                    }
                }
                
                if(!isLocationAvailable){
                    [mArraybathRooms addObject:mDictRestaurantDetail];
                }
            }
            
            while (counter < [mArraybathRooms count]) {
                
                NSMutableDictionary *restaurantDetail = [mArraybathRooms objectAtIndex:counter];
                
                Annotation *ann = [[Annotation alloc] init];
                
                CLLocationCoordinate2D annotationCoord;
                
                NSDictionary *bathroomGeoLocation = [[restaurantDetail objectForKey:@"geometry"] objectForKey:@"location"];
                
                annotationCoord.latitude = [bathroomGeoLocation[@"lat"] doubleValue];
                
                annotationCoord.longitude = [bathroomGeoLocation[@"lng"] doubleValue];
                
                ann.locationType = @"restaurant";
                
                ann.coordinate = annotationCoord;
                
                ann.title = restaurantDetail[@"name"];
                
                _mapView.delegate = self;
                
                ann.tag = counter;
                
                counter++;
                
                [_mapView addAnnotation:ann];
            }
            
            //get Hotel's
            AppDelegate *appDelegate = [AppDelegate getInstance];
            if([appDelegate.strRequestFor isEqualToString:@"NearMe"]){
                [self getHotelsWithLocationName:[[NSUserDefaults standardUserDefaults]valueForKey:@"userCity"]];
            }
            else{
                [self getHotelsWithLocationName:_strSearchLocation];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark -- GET HOTEL'S
-(void)getHotelsWithLocationName:(NSString *)locationName{
    
    //CleanBM key = AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE
    
    // upeepz key = AIzaSyCuTCpdsXmh8pmVjXfis0Ta-dBBwHnwPIw
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=hotel+in+%@&key=AIzaSyCuTCpdsXmh8pmVjXfis0Ta-dBBwHnwPIw",locationName] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            
            NSArray *arrayRestaurant = [responseObject valueForKey:@"results"];
            
            NSInteger counter = mArraybathRooms.count;
            
            NSMutableArray *mArrayHolder = [mArraybathRooms mutableCopy];
            
            for (NSMutableDictionary *mDictHotelDetail in arrayRestaurant) {
                
                BOOL isLocationAvailable = NO;
                
                for (id object in mArrayHolder) {
                    
                    if([object isKindOfClass:[PFObject class]]){
                        
                        PFGeoPoint *bathroomGeoPoint = object[@"bathLocation"];
                        
                        NSDictionary *bathroomGeoLocation = [[mDictHotelDetail objectForKey:@"geometry"] objectForKey:@"location"];
                        
                        double latitude = [bathroomGeoLocation[@"lat"] doubleValue];
                        
                        double longitude = [bathroomGeoLocation[@"lng"] doubleValue];
                        
                        if(bathroomGeoPoint.latitude == latitude && bathroomGeoPoint.longitude == longitude){
                            
                            isLocationAvailable = YES;
                            break;
                        }
                    }
                }
                if(!isLocationAvailable){
                    [mArraybathRooms addObject:mDictHotelDetail];
                }
            }
            
            while (counter < [mArraybathRooms count]) {
                
                NSMutableDictionary *hotelDetail = [mArraybathRooms objectAtIndex:counter];
                
                Annotation *ann = [[Annotation alloc] init];
                
                CLLocationCoordinate2D annotationCoord;
                
                NSDictionary *bathroomGeoLocation = [[hotelDetail objectForKey:@"geometry"] objectForKey:@"location"];
                
                annotationCoord.latitude = [bathroomGeoLocation[@"lat"] doubleValue];
                
                annotationCoord.longitude = [bathroomGeoLocation[@"lng"] doubleValue];
                
                ann.locationType = @"hotel";
                
                ann.coordinate = annotationCoord;
                
                ann.title = hotelDetail[@"name"];
                
                _mapView.delegate = self;
                
                ann.tag = counter;
                
                counter++;
                
                [_mapView addAnnotation:ann];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)addMarkersOnMapWithLatitude:(double)latitude andLongitude:(double)longitude{
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = latitude;
    annotationCoord.longitude = longitude;
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = latitude;
    mapRegion.center.longitude = longitude;
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    MKCoordinateRegion region = {annotationCoord, mapRegion.span};
    [_mapView setRegion:region animated:YES];
}

-(void)configureMenuView{
    
    // do stuff with the user
    REMenuItem *loginSignUpItem = [[REMenuItem alloc] initWithTitle:@"Home"
                                                           subtitle:@""
                                                              image:[UIImage imageNamed:@"home_icon"]
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 NSLog(@"Item: %@", item);
                                                                 
                                                                 [self performSelector:@selector(actionHomePage:) withObject:nil afterDelay:0.3];
                                                             }];
    
    REMenuItem *searchNearMeItem = [[REMenuItem alloc] initWithTitle:@"Search Near Me"
                                                            subtitle:@""
                                                               image:[UIImage imageNamed:@"location_icon"]
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  NSLog(@"Item: %@", item);
                                                                  
                                                                  [self addMarkersOnMapWithLatitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"latitude"] doubleValue] andLongitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"longitude"] doubleValue]];
                                                                  [self getAllBathRoomsWithLatitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"latitude"] doubleValue] andLongitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"longitude"] doubleValue]];
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

#pragma mark--GET BATHROOMS
-(void)getAllBathRoomsWithLatitude:(double)latitude andLongitude:(double)longitude{
    
    _viewHeader.hidden = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:@"BathRoomDetail"];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    
    [query whereKey:@"bathLocation" nearGeoPoint:point withinKilometers:10];
    
    [query whereKey:@"approve" equalTo:@"YES"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(error == nil){
            NSLog(@"Response Data = %@", objects);
            
            NSArray *annotations = [_mapView annotations];
            
            for (int j=0; j < [annotations count]; j++) {
                if ([[annotations objectAtIndex:j] isKindOfClass:[Annotation class]]) {
                    [_mapView removeAnnotation:[annotations objectAtIndex:j]];
                }
            }
            
            _viewHeader.hidden = YES;
            
            mArraybathRooms = [[NSMutableArray alloc]initWithArray:objects];
            
            for (int i =0; i < [mArraybathRooms count]; i++) {
                
                PFObject *bathRoomObject = [mArraybathRooms objectAtIndex:i];
                
                Annotation *ann = [[Annotation alloc] init];
                
                CLLocationCoordinate2D annotationCoord;
                
                PFGeoPoint *bathroomGeoPoint = bathRoomObject[@"bathLocation"];
                
                annotationCoord.latitude = bathroomGeoPoint.latitude;
                
                annotationCoord.longitude = bathroomGeoPoint.longitude;
                
                ann.locationType = @"bathRoom";
                
                ann.coordinate = annotationCoord;
                
                ann.title = bathRoomObject[@"bathFullAddress"];
                
                _mapView.delegate = self;
                
                ann.tag = i;
                
                [_mapView addAnnotation:ann];
            }
            
            AppDelegate *appDelegate = [AppDelegate getInstance];
            
            if([appDelegate.strRequestFor isEqualToString:@"NearMe"]){
                [self getRestaurantsWithLocationName:[[NSUserDefaults standardUserDefaults]valueForKey:@"userCity"]];
            }
            else{
                [self getRestaurantsWithLocationName:_strSearchLocation];
            }
            
        }else{
            if([[error userInfo][@"error"] isEqualToString:@"The Internet connection appears to be offline."]){
                _txtSearchLocation.placeholder = @"Unable to reach our servers";
            }else{
                _txtSearchLocation.placeholder = [error userInfo][@"error"];
            }
        }
    }];
}


-(void)actionSearchLocation{
    
    _viewHeader.hidden = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:@"BathRoomDetail"];
    //[query2 whereKey:@"members" containsIn:@""];
    [query whereKey:@"bathFullAddress" containsString:_strSearchLocation];
    
    [query whereKey:@"approve" equalTo:@"YES"];
    
    //[query whereKey:@"bathFullAddress" matchesRegex:@"Mhow"];
    
    // PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Data =%@",objects);
        
        if(error == nil){
            
            NSArray *annotations = [_mapView annotations];
            
            for (int j=0; j < [annotations count]; j++) {
                if ([[annotations objectAtIndex:j] isKindOfClass:[Annotation class]]) {
                    [_mapView removeAnnotation:[annotations objectAtIndex:j]];
                }
            }
            
            _viewHeader.hidden = YES;
            
            mArraybathRooms = [[NSMutableArray alloc]initWithArray:objects];
            for (int i =0; i < [mArraybathRooms count]; i++) {
                
                PFObject *bathRoomObject = [mArraybathRooms objectAtIndex:i];
                
                Annotation *ann = [[Annotation alloc] init];
                
                CLLocationCoordinate2D annotationCoord;
                
                PFGeoPoint *bathroomGeoPoint = bathRoomObject[@"bathLocation"];
                
                annotationCoord.latitude = bathroomGeoPoint.latitude;
                
                annotationCoord.longitude = bathroomGeoPoint.longitude;
                
                ann.coordinate = annotationCoord;
                
                ann.locationType = @"bathRoom";
                
                ann.title = bathRoomObject[@"bathFullAddress"];
                
                // ann.title = bathRoomObject[@"bathroomFullAddress"];
                
                _mapView.delegate = self;
                
                ann.tag = i;
                
                [_mapView addAnnotation:ann];
                
                if(i == 0 ){
                    
                    MKCoordinateRegion mapRegion;
                    mapRegion.center.latitude = bathroomGeoPoint.latitude;
                    mapRegion.center.longitude = bathroomGeoPoint.longitude;
                    mapRegion.span.latitudeDelta = 0.005;
                    mapRegion.span.longitudeDelta = 0.005;
                    MKCoordinateRegion region = {annotationCoord, mapRegion.span};
                    [_mapView setRegion:region animated:YES];
                }
            }
        }else{
            if([[error userInfo][@"error"] isEqualToString:@"The Internet connection appears to be offline."]){
                _txtSearchLocation.placeholder = @"Unable to reach our servers";
            }else{
                _txtSearchLocation.placeholder = [error userInfo][@"error"];
            }
        }
    }];
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

- (IBAction)actionBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark--
#pragma MENU BUTTON
-(IBAction)actionMenuButton:(id)sender{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.strMenu = @"HomeMenu";
    
    [self menuButton];
}

- (void) menuButton{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
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

-(IBAction)actionHomePage:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[NearMeViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

-(IBAction)actionMyAccount:(id)sender{
    MyAccountViewController *myAccountViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"myAccountViewController"];
    [self.navigationController pushViewController:myAccountViewController animated:YES];
}

#pragma mark--UITEXTFIELD DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MKMapView Delegate.
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
    Annotation *localAnnotation = (Annotation *)annotation;
    
    if (annotationView == nil){
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        //annotationView.annotation = annotation;
    }
    
    if ([localAnnotation.locationType isEqualToString:@"bathRoom"]) {
        annotationView.image = [UIImage imageNamed:@"small_cleanbm_location_icon"];
    }else if([localAnnotation.locationType isEqualToString:@"restaurant"]){
        annotationView.image = [UIImage imageNamed:@"blue_restaurent_icon"];
    }
    else{
        annotationView.image = [UIImage imageNamed:@"blue_hotel_icon"];
    }
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rightButton.tag = localAnnotation.tag;
    [rightButton addTarget:nil action:@selector(eventDetail:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = rightButton;
    annotationView.rightCalloutAccessoryView.hidden = NO;
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    
    return annotationView;
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
}

-(IBAction)eventDetail:(id)sender{
    
    if([sender tag] != 111){
        
        id object = [mArraybathRooms objectAtIndex:[sender tag ]];
        
        if([object isKindOfClass:[PFObject class]]){
            NSLog(@"BathRoom");
            BathRoomDetailViewController *bathRoomDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"bathRoomDetailViewController"];
            bathRoomDetailViewController.bathRoomDetail = [mArraybathRooms objectAtIndex:[sender tag ]];
            
            [self.navigationController pushViewController:bathRoomDetailViewController animated:YES];
        }else{
            NSLog(@"Restaurant | Hotel");
            AddNewLocationViewController *addNewLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNewLocationViewController"];
            addNewLocationViewController.strRequestFor = @"addRestaurant";
            addNewLocationViewController.mDictRestaurantHotelDetail = (NSMutableDictionary *)object;
            addNewLocationViewController.requestFor = 1;
            
            [self.navigationController pushViewController:addNewLocationViewController animated:YES];
        }
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    Annotation *custAnnotation = view.annotation;
    
    if ([custAnnotation.title isEqualToString:@"Current Location"]) {
        return;
    }
    //view.image = [UIImage imageNamed:@"map_marker_icon"];
    
    if ([custAnnotation.locationType isEqualToString:@"bathRoom"]) {
        view.image = [UIImage imageNamed:@"map_marker_icon"];
    }else if([custAnnotation.locationType isEqualToString:@"restaurant"]){
        view.image = [UIImage imageNamed:@"restaurent_location_icon"];
    }
    else{
        view.image = [UIImage imageNamed:@"hotel_location_icon"];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    Annotation *custAnnotation = view.annotation;
    if ([custAnnotation.locationType isEqualToString:@"bathRoom"]) {
        view.image = [UIImage imageNamed:@"small_cleanbm_location_icon"];
    }else if([custAnnotation.locationType isEqualToString:@"restaurant"]){
        view.image = [UIImage imageNamed:@"blue_restaurent_icon"];
    }
    else{
        view.image = [UIImage imageNamed:@"blue_hotel_icon"];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark-- UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 123:
            if(buttonIndex == 1){
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
