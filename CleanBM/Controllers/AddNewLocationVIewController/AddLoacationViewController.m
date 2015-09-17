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

@interface AddLoacationViewController ()<MKMapViewDelegate>{
    
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

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)actionGoToHome:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionAddThisLocation:(id)sender {
    AddNewLocationViewController *addNewLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNewLocationViewController"];
    addNewLocationViewController.strRequestFor = @"addLocation";
    
    [self.navigationController pushViewController:addNewLocationViewController animated:YES];
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
    
   

    
//    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
//
//    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//        if(placemarks.count){
//            
////            NSString *strAddress = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",[placemarks[0] subThoroughfare],[placemarks[0] thoroughfare],[placemarks[0] locality],[placemarks[0] administrativeArea],[placemarks[0] country],[placemarks[0] postalCode],[placemarks[0] ocean]];
//            
//            
//            
//            CLPlacemark *placemark = placemarks[0];
//            NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
//            //NSString *addressString = [lines componentsJoinedByString:@"\n"];
//            //NSLog(@"Address: %@", addressString);
//            
//            
//            //NSString *strAddress = [NSString stringWithFormat:@"%@ %@",[placemarks[0] subThoroughfare],[placemarks[0] thoroughfare]];
//            
//            NSString *strAddress = [NSString stringWithFormat:@"%@",lines[0]];
//            
//            strAddress = [strAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
//            
//            [[NSUserDefaults standardUserDefaults] setValue:strAddress forKey:@"NewLocationFullAddress"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//        }
    //}];
}


-(NSArray *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
//    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",pdblLatitude, pdblLongitude];
//    NSError* error;
//    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
//    // NSLog(@"%@",locationString);
//    
//    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    
//    return [locationString substringFromIndex:6];
    
    
    
    //[self showLoadingView:@"Loading.."];
    NSError *error = nil;
    
    NSString *lookUpString  = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&amp;sensor=false", pdblLatitude,pdblLongitude];
    
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:lookUpString]];
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonResponse options:kNilOptions error:&error];
    
    // NSLog(@"%@",jsonDict);
    
    NSArray* jsonResults = [jsonDict objectForKey:@"results"];
    
    // NSLog(@"%@",jsonResults);
    
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

@end
