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


@interface SearchLocationViewController ()<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate>
{
    NSString *searchTextString;
    NSMutableArray *searchArray;
}
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLocations;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableViewLocations.hidden = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- Action Back
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark--UITABLEVIEW DELEGATE AND DATASOURCE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [searchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strIdentifier = @"searchLocation";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    NSMutableDictionary *mDictAddress = [searchArray objectAtIndex:indexPath.row];
    
    UILabel *lblAddress = (UILabel *)[cell viewWithTag:100];
    lblAddress.text = [mDictAddress valueForKey:@"formatted_address"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *mDictAddress = [searchArray objectAtIndex:indexPath.row];
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = [[[[mDictAddress objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
    annotationCoord.longitude = [[[[mDictAddress objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = [[[[mDictAddress objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
    mapRegion.center.longitude = [[[[mDictAddress objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    MKCoordinateRegion region = {annotationCoord, mapRegion.span};
    
    Annotation *ann = [[Annotation alloc] init];
     ann.coordinate = annotationCoord;
    ann.title = [mDictAddress valueForKey:@"formatted_address"];
    
     _mapView.delegate = self;
     //ann.tag = 111;
    [_mapView addAnnotation:ann];
    
    [_mapView setRegion:region animated:YES];

    _txtLocation.text = @"";
    [self.view endEditing:YES];
    
    _tableViewLocations.hidden = YES;
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
    
//    if(localAnnotation.tag == 111){
//        annotationView.image = [UIImage imageNamed:@"current_location_icon"];
//    }
//    else
    {
        annotationView.image = [UIImage imageNamed:@"small_cleanbm_location_icon"];
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
    //    Annotation *custAnnotation = view.annotation;
    //
    //    if ([custAnnotation.title isEqualToString:@"Current Location"]) {
    //        return;
    //    }
    //
    //    NSLog(@"Data = %@",[mArraybathRooms objectAtIndex:custAnnotation.tag]);
    //
    //    BathRoomDetailViewController *bathRoomDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"bathRoomDetailViewController"];
    //
    //    bathRoomDetailViewController.bathRoomDetail = [mArraybathRooms objectAtIndex:custAnnotation.tag];
    //
    //    [self.navigationController pushViewController:bathRoomDetailViewController animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Search Methods

//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    searchTextString = textField.text;
//    [self updateSearchArray];
//}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    searchTextString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(searchTextString.length != 0){
        [self updateSearchArray];

    }else{
        _tableViewLocations.hidden = YES;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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


@end
