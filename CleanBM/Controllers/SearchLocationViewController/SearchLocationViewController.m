//
//  SearchLocationViewController.m
//  CleanBM
//
//  Created by Developer on 07/09/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "SearchLocationViewController.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"
#import "NearMeViewController.h"
#import "AddLoacationViewController.h"
#import "ViewController.h"
#import "MyAccountViewController.h"
#import "SupportViewController.h"
#import "AppDelegate.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>


@interface SearchLocationViewController ()<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate,REMenuDelegate,UIAlertViewDelegate>
{
    NSString *searchTextString;
    NSMutableArray *searchArray;
    NSMutableArray *mArraybathRooms;
}
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLocations;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


//Google place api
@property NSMutableArray *localSearchQueries;
@property NSMutableArray *pastSearchWords;
@property NSMutableArray *pastSearchResults;
@property NSTimer *autoCompleteTimer;
@property NSString *substring;
@property CLLocationManager *locationManager;


@end


//NSString *const apiKey = @"AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE";

@implementation SearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableViewLocations.hidden = YES;
    
    self.localSearchQueries = [NSMutableArray array];
    self.pastSearchWords = [NSMutableArray array];
    self.pastSearchResults = [NSMutableArray array];
    
    [self configureMenuView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- Action Back
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
                                                                 
                                                                 [self performSelector:@selector(actionHomePage:) withObject:nil afterDelay:0.3];
                                                                 
                                                                 
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
                                                                    
                                                                    //                                                                    [self performSelector:@selector(actionSearchNearMe:) withObject:nil afterDelay:0.3];
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

-(IBAction)actionHomePage:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[NearMeViewController class]])
        {
            [self.navigationController popToViewController:viewController animated:YES];
        }
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

#pragma ACTION SUPPORT CLEANBM AFTER DELAY
-(IBAction)actionAddNewLocation:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    BOOL isAddLoacationAvailabel = NO;
    
    for (UIViewController *viewController in viewControllers) {
        
        if([viewController isKindOfClass:[AddLoacationViewController class]])
        {
            isAddLoacationAvailabel = YES;
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    if(!isAddLoacationAvailabel){
        AddLoacationViewController *addLoacationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addLoacationViewController"];
        [self.navigationController pushViewController:addLoacationViewController animated:YES];
    }
}

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


#pragma mark--UITABLEVIEW DELEGATE AND DATASOURCE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.localSearchQueries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchLocation" forIndexPath:indexPath];
    
    NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
    
    UILabel *lblTitle = (UILabel*)[cell viewWithTag:100];
    
    lblTitle.text = [searchResult[@"terms"] objectAtIndex:0][@"value"];
    
    UILabel *lblDetail = (UILabel*)[cell viewWithTag:200];
    lblDetail.text = searchResult[@"description"];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
    _txtLocation.text = @"";
    
    NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
    
    [self getRestaurantsWithLocationName:[searchResult[@"terms"] objectAtIndex:0][@"value"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=false&key=AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE",searchResult[@"reference"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSMutableDictionary *mDict = (NSMutableDictionary *)responseObject;
        
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [mDict[@"result"][@"geometry"][@"location"][@"lat"] doubleValue];
        annotationCoord.longitude = [mDict[@"result"][@"geometry"][@"location"][@"lng"] doubleValue];
        
        MKCoordinateRegion mapRegion;
        mapRegion.center.latitude = [mDict[@"result"][@"geometry"][@"location"][@"lat"] doubleValue];
        mapRegion.center.longitude = [mDict[@"result"][@"geometry"][@"location"][@"lng"] doubleValue];
        mapRegion.span.latitudeDelta = 0.05;
        mapRegion.span.longitudeDelta = 0.05;
        MKCoordinateRegion region = {annotationCoord, mapRegion.span};
        
        _mapView.delegate = self;
        
        [_mapView setRegion:region animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Please Check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }];
    
    _tableViewLocations.hidden = YES;
    
    mArraybathRooms = [[NSMutableArray alloc]init];
}

-(void)getRestaurantsWithLocationName:(NSString *)locationName{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+%@&key=AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE",locationName] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            NSArray *arrayRestaurant = [responseObject valueForKey:@"results"];
            
            
            NSArray *annotations = [_mapView annotations];
            
            for (int j=0; j < [annotations count]; j++) {
                if ([[annotations objectAtIndex:j] isKindOfClass:[Annotation class]]) {
                    [_mapView removeAnnotation:[annotations objectAtIndex:j]];
                }
            }
            
            NSInteger counter = mArraybathRooms.count;
            
            for (NSMutableDictionary *mDictRestaurantDetail in arrayRestaurant) {
                [mArraybathRooms addObject:mDictRestaurantDetail];
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
            
            [self getHotelsWithLocationName:locationName];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Please Check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

#pragma mark -- GET HOTEL'S
-(void)getHotelsWithLocationName:(NSString *)locationName{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=hotel+in+%@&key=AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE",locationName] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            NSArray *arrayRestaurant = [responseObject valueForKey:@"results"];
            
            NSInteger counter = mArraybathRooms.count;
            
            for (NSMutableDictionary *mDictRestaurantDetail in arrayRestaurant) {
                [mArraybathRooms addObject:mDictRestaurantDetail];
            }
            
            while (counter < [mArraybathRooms count]) {
                
                NSMutableDictionary *restaurantDetail = [mArraybathRooms objectAtIndex:counter];
                
                Annotation *ann = [[Annotation alloc] init];
                
                CLLocationCoordinate2D annotationCoord;
                
                NSDictionary *bathroomGeoLocation = [[restaurantDetail objectForKey:@"geometry"] objectForKey:@"location"];
                
                annotationCoord.latitude = [bathroomGeoLocation[@"lat"] doubleValue];
                
                annotationCoord.longitude = [bathroomGeoLocation[@"lng"] doubleValue];
                
                ann.locationType = @"hotel";
                
                ann.coordinate = annotationCoord;
                
                ann.title = restaurantDetail[@"name"];
                
                _mapView.delegate = self;
                
                ann.tag = counter;
                
                counter++;
                
                [_mapView addAnnotation:ann];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Please Check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }];
    
}


#pragma mark - MKMapView Delegate.
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
    Annotation *localAnnotation = (Annotation *)annotation;
    
    if (annotationView == nil)
    {
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

-(IBAction)eventDetail:(id)sender{
    
    if([sender tag] != 111){
        
    }
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Search Methods
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    self.substring = [NSString stringWithString:textField.text];
    self.substring= [self.substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    self.substring = [self.substring stringByReplacingCharactersInRange:range withString:string];
    
    if ([self.substring hasPrefix:@"+"] && self.substring.length >1) {
        self.substring  = [self.substring substringFromIndex:1];
        NSLog(@"This string: %@ had a space at the begining.",self.substring);
    }
    
    if (self.substring.length != 0) {
        _tableViewLocations.hidden = NO;
        
        [self runScript];
    }else{
        _tableViewLocations.hidden = YES;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
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
    [_tableViewLocations reloadData];
    
    if (![self.pastSearchWords containsObject:self.substring]) {
        [self.pastSearchWords addObject:self.substring];
        NSLog(@"Search: %lu",(unsigned long)self.pastSearchResults.count);
        [self retrieveGooglePlaceInformation:self.substring withCompletion:^(NSArray * results) {
            
            if(results.count > 0){
                if([[results objectAtIndex:0] isKindOfClass:[NSString class]]){
                    _tableViewLocations.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Please Check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    [self.localSearchQueries addObjectsFromArray:results];
                    NSDictionary *searchResult = @{@"keyword":self.substring,@"results":results};
                    [self.pastSearchResults addObject:searchResult];
                    [_tableViewLocations reloadData];
                }
            }else{
                _tableViewLocations.hidden = YES;
                UIAlertView *alert = [[UIAlertView  alloc]initWithTitle:@"CleanBM" message:@"Unable to find this location.Please modified your location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }else {
        for (NSDictionary *pastResult in self.pastSearchResults) {
            if([[pastResult objectForKey:@"keyword"] isEqualToString:self.substring]){
                [self.localSearchQueries addObjectsFromArray:[pastResult objectForKey:@"results"]];
                [_tableViewLocations reloadData];
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
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=500&language=en&key=AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE",searchWord,currentLatitude,currentLongitude];
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
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyCJWHBdeonUF9Gafppf6Ag23NRiUhuuzoE",place];
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

//update seach method where the textfield acts as seach bar
-(void)updateSearchArray
{
    if (searchTextString.length != 0) {
        searchArray = [NSMutableArray array];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false",searchTextString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            searchArray = (NSMutableArray *)[responseObject objectForKey:@"results"];
            
            if([searchArray count] > 0)
            {
                _tableViewLocations.hidden = NO;
                [_tableViewLocations reloadData];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
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
