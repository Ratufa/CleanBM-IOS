//
//  BathRoomDetailViewController.m
//  CleanBM
//
//  Created by Developer on 18/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "BathRoomDetailViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <MapKit/MapKit.h>
#import "TPFloatRatingView.h"
#import "Annotation.h"
#import "RatingViewController.h"
#import "CleanBMLoader.h"
#import "StringUtilityClass.h"
#import "Constant.h"
#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import "ViewController.h"
#import "UzysAssetsPickerController.h"
#import "AppDelegate.h"
#import "AddNewLocationViewController.h"


@interface BathRoomDetailViewController ()<UITableViewDataSource,UITableViewDelegate,TPFloatRatingViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout,UzysAssetsPickerControllerDelegate>
{
    NSMutableArray *mArrayBathRoomImages;
    NSMutableArray *mArrayBathRoomReviews;
    UIImage *imageUploaded;
    NSInteger selectedIndex;
    NSMutableArray *mArrayUloadPhoto;
    BOOL isPhotoUplaoding;
}

@property (weak, nonatomic) IBOutlet UILabel *lblNoimagesAvailable;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *lblBathRoomName;
@property (weak, nonatomic) IBOutlet UILabel *lblBathRoomFullAddress;
@property (weak, nonatomic) IBOutlet TPFloatRatingView *bathRoomAverageRating;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalRating;

@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewBathImages;

@property (weak, nonatomic) IBOutlet UITextView *txtDescription;

@property (weak, nonatomic) IBOutlet UITableView *tableViewReviewRating;

@end

@implementation BathRoomDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mapView.delegate = self;
    
    [self addMarkersOnMap];
    
    [self getBathRoomImages];
    
    _lblBathRoomName.text = _bathRoomDetail[@"bathLocationName"];
    _lblBathRoomFullAddress.text = _bathRoomDetail[@"bathFullAddress"];
    _txtDescription.text = _bathRoomDetail[@"description"];
    mArrayUloadPhoto = [[NSMutableArray alloc]init];
    
    isPhotoUplaoding = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!isPhotoUplaoding){
        [self getReviewList];
    }
}

#pragma MENU BUTTON
-(IBAction)actionMenuButton:(id)sender{
    
}

- (IBAction)actionAddPhoto:(id)sender {

//    PFUser *currentUser = [PFUser currentUser];
//    if (currentUser) {
//        // do stuff with the user
//        
//        UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
//        picker.delegate = self;
//        
//        picker.maximumNumberOfSelectionVideo = 0;
//        picker.maximumNumberOfSelectionPhoto = 10;
//        [self presentViewController:picker animated:YES completion:^{
//        }];
//        
//    } else {
//        // show the signup or login screen
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
//        alert.tag = 123;
//        
//        [alert show];
//        return;
//    }
}

#pragma mark--UIImagePickerController DELEGATE
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    imageUploaded = info[UIImagePickerControllerEditedImage];
    
    // self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:^{
        
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            // do stuff with the user
        } else {
            // show the signup or login screen
            [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please Login first!"];
            return;
        }
        
        [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
        
        // Convert to JPEG with 50% quality
        NSData* data = UIImageJPEGRepresentation(imageUploaded, 0.5f);
        
        PFFile *file = [PFFile fileWithName:@"Image.jpg" data:data];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Handle success or failure here ...
            
            if (!error) {
                // The image has now been uploaded to Parse. Associate it with a new object
                PFObject* bathtoomImage = [PFObject objectWithClassName:@"BathroomImages"];
                [bathtoomImage setObject:file forKey:@"bathroomImage"];
                bathtoomImage[@"userId"] = currentUser.objectId;
                bathtoomImage[@"bathroomID"] = [_bathRoomDetail objectId];
                NSLog(@"bathtoomDetailWith ROW ID %@",[_bathRoomDetail objectId]);
                [bathtoomImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [[[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Bathroom added successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        [self getBathRoomImages];
                        
                    }else{
                        NSString *errorString = [error userInfo][@"error"];
                        // Show the errorString somewhere and let the user try again.
                        [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    }
                }];
            }
            
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
            
        } progressBlock:^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
            NSLog(@"Uploading %d",percentDone);
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)actionGiveRating:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
//        RatingViewController *ratingViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ratingViewController"];
//        ratingViewController.strBathRoomId = _bathRoomDetail.objectId;
//        ratingViewController.bathRoomDetail = _bathRoomDetail;
//        ratingViewController.mArrayReviewsList = mArrayBathRoomReviews;
//        [self.navigationController pushViewController:ratingViewController animated:YES];
        
        AddNewLocationViewController *addNewLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNewLocationViewController"];
        addNewLocationViewController.requestFor = 2;
        addNewLocationViewController.mArrayReviewsList = mArrayBathRoomReviews;
        addNewLocationViewController.strBathRoomId = _bathRoomDetail.objectId;
        addNewLocationViewController.bathRoomDetail = _bathRoomDetail;
        [self.navigationController pushViewController:addNewLocationViewController animated:YES];
        
    }else {
        // show the signup or login screen
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
        alert.tag = 123;
        
        [alert show];
        return;
    }
}

-(void)addMarkersOnMap{
    
    PFGeoPoint *bathroomGeoPoint = _bathRoomDetail[@"bathLocation"];
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = bathroomGeoPoint.latitude;
    annotationCoord.longitude = bathroomGeoPoint.longitude;
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = bathroomGeoPoint.latitude;
    mapRegion.center.longitude = bathroomGeoPoint.longitude;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    MKCoordinateRegion region = {annotationCoord, mapRegion.span};
    
    Annotation *ann = [[Annotation alloc] init];
    ann.coordinate = annotationCoord;
    
    _mapView.delegate = self;
    [_mapView addAnnotation:ann];

    [_mapView setRegion:region animated:YES];
    _mapView.scrollEnabled = NO;
}

-(void)getBathRoomImages{
    
    _lblNoimagesAvailable.hidden = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"BathroomImages"];
    [query whereKey:@"bathroomID" equalTo:_bathRoomDetail.objectId];
    [query whereKey:@"approve" equalTo:@"YES"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", (int)objects.count);
            
            mArrayBathRoomImages = [[NSMutableArray alloc] initWithArray:objects];

            if([mArrayBathRoomImages count] > 0){
               _lblNoimagesAvailable.hidden = YES;
            }else{
                _lblNoimagesAvailable.hidden = NO;
            }
            
            [_collectionViewBathImages reloadData];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)getReviewList{
    
    [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];

    PFQuery *query = [PFQuery queryWithClassName:@"RattingByUser"];
    
    [query whereKey:@"bathRoomID" equalTo:_bathRoomDetail.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", (int)objects.count);
            if([objects count] > 1){
                _lblTotalRating.text = [NSString stringWithFormat:@"%lu Reviews",(unsigned long)objects.count];
            }else{
                _lblTotalRating.text = [NSString stringWithFormat:@"%lu Review",(unsigned long)objects.count];
            }
            
            mArrayBathRoomReviews = [[NSMutableArray alloc] init];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:objects];
            
            float rating = 0.0;
            
            for (PFObject *object in tempArray) {
                rating = rating + [object[@"bathRating"] floatValue];
                
                NSDate *currentDate = [NSDate date];
                
                NSDate *created = [object updatedAt];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd:MM:YYYY"];
                
                if([[dateFormat stringFromDate:created] isEqualToString:[dateFormat stringFromDate:currentDate]]){
                    [mArrayBathRoomReviews addObject:object];
                }
            }

            mArrayBathRoomReviews = [self sortingArrayByUpdatedDate:mArrayBathRoomReviews];
            
            tempArray = [self sortingArray:tempArray];
            
            for (PFObject *object in tempArray) {
                
                if (![mArrayBathRoomReviews containsObject:object]) {
                    // ...
                    [mArrayBathRoomReviews addObject:object];
                }
            }
            
            rating = rating/[mArrayBathRoomReviews count];
            _bathRoomAverageRating.delegate = self;
            _bathRoomAverageRating.emptySelectedImage = [UIImage imageNamed:@"unselected_rating"];
            _bathRoomAverageRating.fullSelectedImage = [UIImage imageNamed:@"selected_rating"];
            _bathRoomAverageRating.contentMode = UIViewContentModeScaleAspectFill;
             _bathRoomAverageRating.maxRating = 5;
             _bathRoomAverageRating.minRating = 0;
            _bathRoomAverageRating.rating = rating;
            _bathRoomAverageRating.editable = NO;
            
            [_tableViewReviewRating reloadData];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
    }];
}


-(NSMutableArray *)sortingArrayByUpdatedDate:(NSMutableArray *)sortArray
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedAt"
                                                 ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [sortArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return [[NSMutableArray alloc] initWithArray:sortedArray];
}


-(NSMutableArray *)sortingArray:(NSMutableArray *)sortArray
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likeCount"
                                                 ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [sortArray sortedArrayUsingDescriptors:sortDescriptors];
    
    // _arrayOrderStatus = [[dictResponse valueForKey:@"order_array"] mutableCopy];
    
    return [[NSMutableArray alloc] initWithArray:sortedArray];
}



#pragma mark - MKMapView Delegate.
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
//    if ([annotation isKindOfClass:[MKUserLocation class]]){
//        return nil;
//    }
//    
//    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
//    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
//    
//    if (annotationView == nil){
//        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
//    }
//    
//    annotationView.image = [UIImage imageNamed:@"small_cleanbm_location_icon"];
//    annotationView.rightCalloutAccessoryView.hidden = YES;
//    annotationView.canShowCallout = YES;
//    annotationView.draggable = YES;
//    
//    return annotationView;
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
   // Annotation *localAnnotation = (Annotation *)annotation;
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        //annotationView.annotation = annotation;
    }
    
    annotationView.image = [UIImage imageNamed:@"small_cleanbm_location_icon"];
    
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{

    UIAlertView *alertRoot = [[UIAlertView alloc]
                  initWithTitle:@"CleanBM"
                  message:@"Find Route"
                  delegate:self
                  cancelButtonTitle:@"Cancel"
                  otherButtonTitles:@"Google Maps", @"Apple Maps", nil];
    
    alertRoot.tag = 888;
    [alertRoot show];
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    
    NSArray *annotations = [_mapView annotations];
    
    for (int j=0; j < [annotations count]; j++) {
        if ([[annotations objectAtIndex:j] isKindOfClass:[Annotation class]]) {
            [_mapView removeAnnotation:[annotations objectAtIndex:j]];
        }
    }
    
    [self addMarkersOnMap];
}

#pragma mark--UITABLEVIEW DELEGATE AND DATASOURCE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [mArrayBathRoomReviews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *strIdentifier = @"BathroomReviews";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    PFObject *object = [mArrayBathRoomReviews objectAtIndex:indexPath.row];
    
    UILabel *lblUserName = (UILabel *)[cell viewWithTag:100];
    
    lblUserName.text = object[@"userName"];
    
    UITextView *txtMessage = (UITextView *)[cell viewWithTag:200];
    txtMessage.text = object[@"MessageReview"];
    
    TPFloatRatingView *ratingView = (TPFloatRatingView *)[cell viewWithTag:300];
    ratingView.delegate = self;
    ratingView.emptySelectedImage = [UIImage imageNamed:@"unselected_rating"];
    ratingView.fullSelectedImage = [UIImage imageNamed:@"selected_rating"];
    ratingView.contentMode = UIViewContentModeScaleAspectFill;
    ratingView.maxRating = 5;
    ratingView.minRating = 0;
    ratingView.rating = [object[@"bathRating"] floatValue];
    ratingView.editable = NO;
    
    return cell;
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Like" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        NSLog(@"Action to perform with Button 1");
                                        
                                        PFObject *objectReview = [mArrayBathRoomReviews objectAtIndex:indexPath.row];

                                        PFUser *currentUser = [PFUser currentUser];
                                        if (currentUser) {
                                            // do stuff with the user
                                            
                                            PFQuery *query = [PFQuery queryWithClassName:@"LikeReview"];

                                            [query whereKey:@"likeUser" containsString:currentUser.objectId];
                                            
                                            PFQuery *query2 = [PFQuery queryWithClassName:@"LikeReview"];
                                         
                                            [query2 whereKey:@"reviewId" containsString:objectReview.objectId];
                                            
                                             PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
                                            
                                            
                                            
                                            [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                                NSLog(@"Data =%@",objects);
                                                
                                                for (int i = 0; i < [objects count]; i++) {
                                                    
                                                    PFObject *objectData = [objects objectAtIndex:i];
                                                    
                                                    if ([objectData[@"likeUser"] isEqualToString:currentUser.objectId] && [objectData[@"reviewId"] isEqualToString:objectReview.objectId]) {
                                                        
                                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"You have already like." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                        [alert show];
                                                        ;
                                                        return ;
                                                    }
                                                    
                                                }
                                                
                                               
                                                
                                                if(error == nil){
                                                    
                                                    PFObject* bathtoomRating = [PFObject objectWithClassName:@"LikeReview"];
                                                    
                                                    bathtoomRating[@"likeUser"] = currentUser.objectId;
                                                    bathtoomRating[@"reviewId"] = objectReview.objectId;
                                                    bathtoomRating[@"likeCount"] = [NSNumber numberWithInt:1];
                                                    bathtoomRating[@"reviewUserId"] = objectReview[@"userId"];
                                                    bathtoomRating[@"bathroomId"] = [_bathRoomDetail objectId];
                                                    
                                                    [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                        
                                                        if(succeeded){
                                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Like successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                            //alert.tag = 999;
                                                            [alert show];
                                                            
                                                            NSNumber *incrementedNumber = [NSNumber numberWithInt:1];

                                                            [objectReview incrementKey:@"likeCount" byAmount:incrementedNumber];
                                                            [objectReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                                [self getReviewList];
                                                            }];
                                                            
                                                        }else{
                                                            NSString *errorString = [error userInfo][@"error"];
                                                            // Show the errorString somewhere and let the user try again.
                                                            [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                                        }
                                                        [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                                                    }];
                                                    
                                                }else{
                                                    [[[UIAlertView alloc] initWithTitle:@"CleanBM" message:[error userInfo][@"error"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                                }
                                            }];
                                            
                                        } else {
                                            // show the signup or login screen
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
                                            alert.tag = 123;
                                            
                                            [alert show];
                                            return;
                                        }
                                    }];
    button.backgroundColor = [UIColor redColor]; //arbitrary color
    
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Report" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         NSLog(@"Action to perform with Button2!");
                                         
                                         selectedIndex = indexPath.row;
                                         
                                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Report as inappropriate?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                                         alert.tag = 100;
                                         [alert show];
                                     }];
    button2.backgroundColor = [UIColor blueColor]; //arbitrary color
    
    return @[button, button2]; //array with all the buttons you want. 1,2,3, etc...
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // you need to implement this method too or nothing will work:
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; //tableview must be editable or nothing will work...
}

#pragma mark--UICOLLECTIONVIEW DELEGATE AND DATASOURCE
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [mArrayBathRoomImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewBathImages" forIndexPath:indexPath];
    
    UIImageView *imgViewBathroom = (UIImageView *)[cell viewWithTag:100];
    
    imgViewBathroom.image = [UIImage imageNamed:@"bg"];
    
    PFFile *imageFile = [[mArrayBathRoomImages objectAtIndex:indexPath.item] objectForKey:@"bathroomImage"];
    
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            imgViewBathroom.image = image;
            
            [self displayImage:imgViewBathroom withImage:image];
        }
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(IS_IPHONE_4 || IS_IPHONE_5){
        return CGSizeMake(80, 72);
    }else if (IS_IPHONE_6){
        return CGSizeMake(98.33, 78);
    }
    else{
        return CGSizeMake(111.33, 72);
    }
}

-(IBAction)actionBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) displayImage:(UIImageView*)imageView withImage:(UIImage*)image  {
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setupImageViewer];
    imageView.clipsToBounds = YES;
}

#pragma mark -- Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 888:{
            PFGeoPoint *bathroomGeoPoint = _bathRoomDetail[@"bathLocation"];
            NSString *latitude = [NSString stringWithFormat:@"%f",bathroomGeoPoint.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",bathroomGeoPoint.longitude];
            
            if (buttonIndex == 1) {
                
                CGFloat latDestination = 0;
                CGFloat logDestination = 0;
                
                latDestination = [latitude floatValue];
                logDestination = [longitude floatValue];
                
                CGFloat latCurrent = [[[NSUserDefaults standardUserDefaults]valueForKey:@"latitude"]floatValue];
                CGFloat logCurrent = [[[NSUserDefaults standardUserDefaults]valueForKey:@"longitude"]floatValue];
                
                if ([[UIApplication sharedApplication] canOpenURL:
                     [NSURL URLWithString:@"comgooglemaps://"]]){
                    [[UIApplication sharedApplication] openURL:
                     [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%.6f,%.6f&daddr=%.6f,%.6f&directionsmode=driving",latCurrent,logCurrent,latDestination,logDestination]]];
                }
                else{
                    [[UIApplication sharedApplication] openURL:
                     [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%.6f,%.6f&daddr=%.6f,%.6f&directionsmode=driving",latCurrent,logCurrent,latDestination,logDestination]]];
                }
            }
            else if (buttonIndex == 2){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?saddr=Current+Location&daddr=%@,%@",latitude,longitude]]];
            }
        }
            break;
        case 100:{
            if(buttonIndex == 0){
                //inappropriate Report
                PFObject *objectReview = [mArrayBathRoomReviews objectAtIndex:selectedIndex];
                
                PFUser *currentUser = [PFUser currentUser];
                
                if (currentUser) {
                    // do stuff with the user
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"ReportReview"];
                    
                    [query whereKey:@"reportedUser" containsString:currentUser.objectId];
                    
                    PFQuery *query2 = [PFQuery queryWithClassName:@"ReportReview"];
                    
                    [query2 whereKey:@"reviewId" containsString:objectReview.objectId];
                    
                    PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
                    
                    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        NSLog(@"Data =%@",objects);
                        
                        for (int i = 0; i < [objects count]; i++) {
                            
                            PFObject *objectData = [objects objectAtIndex:i];
                            
                            if ([objectData[@"reportedUser"] isEqualToString:currentUser.objectId] && [objectData[@"reviewId"] isEqualToString:objectReview.objectId]) {
                                
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"You have reported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [alert show];
                                ;
                                return ;
                            }
                        }
                        
                        if(error == nil){
                            
                            PFObject* bathtoomRating = [PFObject objectWithClassName:@"ReportReview"];
                            
                            bathtoomRating[@"reportedUser"] = currentUser.objectId;//who login user
                            bathtoomRating[@"reviewId"] = objectReview.objectId;
                            bathtoomRating[@"reportCount"] = [NSNumber numberWithInt:1];
                            bathtoomRating[@"reviewUserId"] = objectReview[@"userId"];
                            bathtoomRating[@"bathroomId"] = [_bathRoomDetail objectId];
                            
                            [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                if(succeeded){
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"You have successfully reported Inappropriate content." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    //alert.tag = 555;
                                    [alert show];
                                    
                                    NSNumber *incrementedNumber = [NSNumber numberWithInt:1];
                                    
                                    [objectReview incrementKey:@"reportCount" byAmount:incrementedNumber];
                                    [objectReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        //[self getReviewList];
                                    }];
                                    
                                }else{
                                    NSString *errorString = [error userInfo][@"error"];
                                    // Show the errorString somewhere and let the user try again.
                                    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                }
                                [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                            }];
                        }else{
                            [[[UIAlertView alloc] initWithTitle:@"CleanBM" message:[error userInfo][@"error"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        }
                    }];
                    
                } else {
                    // show the signup or login screen
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
                    alert.tag = 123;
                    [alert show];
                    return;
                }
            }
        }
            break;
        case 123:{
            if(buttonIndex == 0){
                //Login
                ViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
                
                AppDelegate *appDelegate = [AppDelegate getInstance];
                appDelegate.strRootOrLogin = @"LoginViewController";
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
            break;
        case 111:
        {
            if(buttonIndex == 0)
            {
                //Upload Photo
                isPhotoUplaoding = YES;
                PFUser *currentUser = [PFUser currentUser];
                [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
                
                [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:_bathRoomDetail.objectId withIndex:0];
            }
        }
        default:
            break;
    }
}


-(void)uploadImagesOnServerWithUserId:(NSString *)userId andBathRoomID:(NSString *)bathroomId withIndex:(NSInteger)index{
    
    __block NSInteger blockInteger = index;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        @autoreleasepool {
            CGImageRef iref = [rep fullScreenImage];
            if (iref) {
                UIImage *image = [UIImage imageWithCGImage:iref];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //UIMethod trigger...
                    
                    NSData* data = UIImageJPEGRepresentation(image, 0.5f);
                    
                    PFFile *file = [PFFile fileWithName:@"Image.jpg" data:data];
                    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        // Handle success or failure here ...
                        
                        if (!error) {
                            // The image has now been uploaded to Parse. Associate it with a new object
                            PFObject* bathtoomImage = [PFObject objectWithClassName:@"BathroomImages"];
                            [bathtoomImage setObject:file forKey:@"bathroomImage"];
                            bathtoomImage[@"userId"] = userId;
                            bathtoomImage[@"bathroomID"] = bathroomId;
                            bathtoomImage[@"approve"] = @"NO";
                            
                            [bathtoomImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if(succeeded){
                                    if(blockInteger < [mArrayUloadPhoto count]-1)
                                    {
                                        blockInteger++;
                                        [self uploadImagesOnServerWithUserId:userId andBathRoomID:bathroomId withIndex:blockInteger];
                                    }
                                    else{
                                        [self getBathRoomImages];

                                        isPhotoUplaoding = NO;
                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Images uploaded successfully and waiting for approval!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        
                                        [alert show];
                                        [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                                    }
                                }else{
                                    NSString *errorString = [error userInfo][@"error"];
                                    // Show the errorString somewhere and let the user try again.
                                    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                }
                            }];
                        }
                        else{
                            [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                        }
                    } progressBlock:^(int percentDone) {
                        // Update your progress spinner here. percentDone will be between 0 and 100.
                        NSLog(@"Uploading %d",percentDone);
                    }];
                });
                iref = nil;
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
    };
    
    NSMutableDictionary *mDictUploadImage = [mArrayUloadPhoto objectAtIndex:index];
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:[mDictUploadImage objectForKey:@"imageURL"]
                   resultBlock:resultblock
                  failureBlock:failureblock];
}

#pragma mark - UzysAssetsPickerControllerDelegate methods
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    if([assets count] > 0){
        
        NSString *strMessage = [NSString stringWithFormat:@"Do you want to upload %lu images?",(unsigned long)[assets count]];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:strMessage delegate:self cancelButtonTitle:@"Upload" otherButtonTitles:@"Cancel", nil];
        alert.tag = 111;
        [alert show];
    }
    
    for (int i = 0; i < [assets count]; i++) {
        
        NSURL *url= (NSURL*) [[assets[i] valueForProperty:ALAssetPropertyURLs] valueForKey:[[[assets[i] valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
        
        NSMutableDictionary *mDictUploadImage = [[NSMutableDictionary alloc] init];
        [mDictUploadImage setObject:url forKey:@"imageURL"];
        [mArrayUloadPhoto addObject:mDictUploadImage];
    }
}

- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"Exceed Maximum Number Of Selection", @"UzysAssetsPickerController", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


//@Yogendra
#pragma mark -- Previous
- (IBAction)actionPreviousButtonPressed:(id)sender
{
    CGFloat width;
    if(IS_IPHONE_4 || IS_IPHONE_5){
        width = 90;
    }else if (IS_IPHONE_6){
        width = 108;
    }
    else{
        width = 121.3;
    }
    
    NSLog(@"contentOffset.x == %f",_collectionViewBathImages.contentOffset.x);
    
    if (_collectionViewBathImages.contentOffset.x > 0 ){
        CGRect frame;
        frame.origin.x = _collectionViewBathImages.contentOffset.x - width;
        frame.origin.y = 0;
        frame.size = _collectionViewBathImages.frame.size;
        
        [_collectionViewBathImages scrollRectToVisible:frame animated:YES];
        
//       // [_btnNext setImage:[UIImage imageNamed:@"right_back"] forState:UIControlStateNormal];
//        
//        if (_collectionViewBathImages.contentOffset.x > 0) {
//            [_btnPrevious setImage:[UIImage imageNamed:@"left_back_blue"] forState:UIControlStateNormal];
//            
//        }else{
//            [_btnPrevious setImage:[UIImage imageNamed:@"left_back"] forState:UIControlStateNormal];
//            
//        }
        
    }
}

#pragma mark -- RightArrow Footer2
- (IBAction)actionNextButtonPressed:(id)sender
{
    CGFloat width;
    if(IS_IPHONE_4 || IS_IPHONE_5){
        width = 90;
    }else if (IS_IPHONE_6){
        width = 108;
    }
    else{
        width = 121.33;
    }

    NSLog(@"contentOffset.x == %f",_collectionViewBathImages.contentOffset.x);

    if ( _collectionViewBathImages.contentOffset.x < _collectionViewBathImages.contentSize.width - (width * 3)){
        CGRect frame;
        frame.origin.x = _collectionViewBathImages.contentOffset.x  + width;
        frame.origin.y = 0;
        frame.size = _collectionViewBathImages.frame.size;
        
        [_collectionViewBathImages scrollRectToVisible:frame animated:YES];
        
        //[_btnNext setImage:[UIImage imageNamed:@"right_back"] forState:UIControlStateNormal];
        //[_btnPrevious setImage:[UIImage imageNamed:@"left_back_blue"] forState:UIControlStateNormal];
        
    }else{
        
        //[_btnNext setImage:[UIImage imageNamed:@"right_back_gray"] forState:UIControlStateNormal];
        
    }
}

@end
