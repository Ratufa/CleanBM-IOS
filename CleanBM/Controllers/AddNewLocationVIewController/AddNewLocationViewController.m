//
//  AddNewLocationViewController.m
//  CleanBM
//
//  Created by Developer on 11/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "AddNewLocationViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "TPFloatRatingView.h"
#import <Parse/Parse.h>
#import "StringUtilityClass.h"
#import "CleanBMLoader.h"
#import "UzysAssetsPickerController.h"
#import "ViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "NearMeViewController.h"
#import "SearchLocationViewController.h"
#import "MyAccountViewController.h"
#import "SupportViewController.h"


@interface AddNewLocationViewController ()<TPFloatRatingViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UzysAssetsPickerControllerDelegate,UIGestureRecognizerDelegate,REMenuDelegate>
{
    UIImage *imageUploaded;
    CGFloat bathroomRating;
    NSString *strBathRoomType;
    NSMutableArray *mArrayUloadPhoto;
    
    NSString *strBathRoomBasedOn;
    
    PFObject *reviewObject;
    BOOL isGivenRating;
}


@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewUploadImages;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet TPFloatRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UITextField *txtLocationName;

@property (weak, nonatomic) IBOutlet UITextView *txtViewMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnSquat;

@property (weak, nonatomic) IBOutlet UIButton *btnSit;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;


@property (weak, nonatomic) IBOutlet UIImageView *imgMale;
@property (weak, nonatomic) IBOutlet UIImageView *imgFeMale;
@property (weak, nonatomic) IBOutlet UIImageView *imgMaleFeMaleBoth;

@end

@implementation AddNewLocationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _collectionViewUploadImages.hidden = YES;
    mArrayUloadPhoto = [[NSMutableArray alloc] init];

    
    [self configureMenuView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _ratingView.delegate = self;
    _ratingView.emptySelectedImage = [UIImage imageNamed:@"unselected_rating"];
    _ratingView.fullSelectedImage = [UIImage imageNamed:@"selected_rating"];
    _ratingView.contentMode = UIViewContentModeScaleAspectFill;
    _ratingView.maxRating = 5;
    _ratingView.minRating = 0;
    _ratingView.rating = 0.0;
    _ratingView.editable = YES;
    _ratingView.halfRatings = NO;
    _ratingView.floatRatings = YES;
    
    if(_requestFor == 1){
        
        //Squat Bathroom
        [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
        [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
        strBathRoomType = @"Squat";
        
        if([_strRequestFor isEqualToString:@"addLocation"])
        {
            if([[[NSUserDefaults standardUserDefaults]valueForKey:@"NewLocationFullAddress"] isEqualToString:@""]){
                _txtLocationName.text = @"";
                _txtLocationName.userInteractionEnabled = YES;
            }else{
                _txtLocationName.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"NewLocationFullAddress"];
                _txtLocationName.userInteractionEnabled = NO;
            }
            
        }else{
            _txtLocationName.text = [_mDictRestaurantHotelDetail valueForKey:@"name"];
            
            NSDictionary *bathroomGeoLocation = [[_mDictRestaurantHotelDetail objectForKey:@"geometry"] objectForKey:@"location"];
            
            [[NSUserDefaults standardUserDefaults]setValue:bathroomGeoLocation[@"lat"] forKey:@"AddLocationLatitude"];
            [[NSUserDefaults standardUserDefaults]setValue:bathroomGeoLocation[@"lng"] forKey:@"AddLocationLongitude"];
        }
        _imgMale.image = [UIImage imageNamed:@"radio_button"];
        _imgFeMale.image = [UIImage imageNamed:@"unsel_radio_button"];
        _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"unsel_radio_button"];
        
        strBathRoomBasedOn = @"Male";
        
        isGivenRating = NO;
        
    }
    else{
        PFUser *currentUser = [PFUser currentUser];
        if ([_bathRoomDetail[@"genderType"] isEqualToString:@"Male"]) {
            
            _imgMale.image = [UIImage imageNamed:@"radio_button"];
            _imgFeMale.image = [UIImage imageNamed:@"unsel_radio_button"];
            _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"unsel_radio_button"];
        }
        else if([_bathRoomDetail[@"genderType"] isEqualToString:@"Female"]){
            _imgMale.image = [UIImage imageNamed:@"unsel_radio_button"];
            _imgFeMale.image = [UIImage imageNamed:@"radio_button"];
            _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"unsel_radio_button"];
        }
        else{
            _imgMale.image = [UIImage imageNamed:@"unsel_radio_button"];
            _imgFeMale.image = [UIImage imageNamed:@"unsel_radio_button"];
            _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"radio_button"];
        }
        
        _txtLocationName.text = _bathRoomDetail[@"bathFullAddress"];
        
        if([_bathRoomDetail[@"bathRoomType"] isEqualToString:@"Squat"]){
            //Squat Bathroom
            [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
            [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
            strBathRoomType = @"Squat";
        }else{
            //Sit Bathroom
            [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
            [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
            strBathRoomType = @"Sit";
        }

        for (PFObject *pfObject in _mArrayReviewsList) {
            
            if(currentUser){
                if([currentUser.objectId isEqualToString:pfObject[@"userId"]] && [_strBathRoomId isEqualToString:pfObject[@"bathRoomID"]]){
                    reviewObject = pfObject;
                    
                    isGivenRating = YES;
                    
                    _ratingView.rating = [pfObject[@"bathRating"]floatValue];
                    
                    if([pfObject[@"bathRoomType"] isEqualToString:@"Squat"]){
                        //Squat Bathroom
                        [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
                        [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
                        strBathRoomType = @"Squat";
                    }else{
                        //Sit Bathroom
                        [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
                        [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
                        strBathRoomType = @"Sit";
                    }
                    _txtViewMessage.text = pfObject[@"MessageReview"];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(IBAction)actionBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark RatingView delegate
- (void)floatRatingView:(TPFloatRatingView *)ratingView ratingDidChange:(CGFloat)rating
{
    NSLog(@"rate value = %f", rating);
    bathroomRating = rating;
}

- (void)floatRatingView:(TPFloatRatingView *)ratingView continuousRating:(CGFloat)rating{
    NSLog(@"rate value = %f", rating);
    bathroomRating = rating;
}

- (IBAction)actionTakePhoto:(id)sender {
    
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
   
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 10;
    [self presentViewController:picker animated:YES completion:^{
    }];
    
}

#pragma mark - UzysAssetsPickerControllerDelegate methods
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if([assets count] > 0){
        _collectionViewUploadImages.hidden = NO;
        _btnCamera.hidden = YES;
    }
    
    DLog(@"assets %@",assets);

    for (int i = 0; i < [assets count]; i++) {
        
        NSURL *url= (NSURL*) [[assets[i] valueForProperty:ALAssetPropertyURLs] valueForKey:[[[assets[i] valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
        
        NSMutableDictionary *mDictUploadImage = [[NSMutableDictionary alloc] init];
        [mDictUploadImage setObject:url forKey:@"imageURL"];
        [mDictUploadImage setValue:@"NO" forKey:@"Selected"];
        [mArrayUloadPhoto addObject:mDictUploadImage];
        }
    [_collectionViewUploadImages reloadData];
    
}

- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"Exceed Maximum Number Of Selection", @"UzysAssetsPickerController", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)actionBathroomType:(id)sender {
    switch ([sender tag]) {
        case 111:{
            //Squat Bathroom
            [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
            [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
            strBathRoomType = @"Squat";
        }
            break;
        case 222:{
            //Sit Bathroom
            [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
            [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
            strBathRoomType = @"Sit";
        }
            break;
        default:
            break;
    }
}

- (IBAction)actionAddLocation:(id)sender {
    
    if ([StringUtilityClass Trim:_txtLocationName.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter location."];
        return;
    }
    
    if ([StringUtilityClass Trim:strBathRoomType].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please select bathroom type Squat/Sit."];
        return;
    }

    if ([StringUtilityClass Trim:_txtViewMessage.text].length == 0){
        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please write a message."];
        return;
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        
        if(_requestFor == 1){
           
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
            
            PFObject* bathtoomDetail = [PFObject objectWithClassName:@"BathRoomDetail"];
            
            bathtoomDetail[@"userInfo"] = currentUser;;
            
            bathtoomDetail[@"userId"] = currentUser.objectId;
            
            bathtoomDetail[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
            bathtoomDetail[@"description"] = _txtViewMessage.text;
            bathtoomDetail[@"bathRoomType"] = strBathRoomType;
            bathtoomDetail[@"approve"]= @"YES";
            bathtoomDetail[@"bathFullAddress"] = _txtLocationName.text;
            
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"AddLocationLatitude"] doubleValue] longitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"AddLocationLongitude"] doubleValue]];
            
            bathtoomDetail[@"bathLocation"] = point;
            
            [bathtoomDetail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved");
                    
                    PFObject* bathtoomRating = [PFObject objectWithClassName:@"RattingByUser"];
                    
                    bathtoomRating[@"userId"] = currentUser.objectId;
                    bathtoomRating[@"userInfo"] = currentUser;
                    bathtoomRating[@"userName"] = currentUser[@"name"];
                    bathtoomRating[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
                    bathtoomRating[@"MessageReview"] = _txtViewMessage.text;
                    bathtoomRating[@"bathRoomType"] = strBathRoomType;
                    bathtoomRating[@"bathRoomID"] = [bathtoomDetail objectId];
                    bathtoomRating[@"bathInfo"] = bathtoomDetail;
                    
                    [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if(succeeded){
                            
                            if([mArrayUloadPhoto count] > 0){
                                
                                [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:[bathtoomDetail objectId]withIndex:0 withBathDetail:bathtoomDetail];
                            }else{
                                //BathRoom Added without Image
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you for your Submission" message:@"Your location has been added successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                alert.tag = 123;
                                [alert show];
                                [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                            }
                        }else{
                            NSString *errorString = [error userInfo][@"error"];
                            // Show the errorString somewhere and let the user try again.
                            [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        }
                        //[CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                    }];
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    NSString *errorString = [error userInfo][@"error"];
                    // Show the errorString somewhere and let the user try again.
                    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                }
            }];
            
        }
        else{
            
            if(isGivenRating){
                
                [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
                PFQuery *query = [PFQuery queryWithClassName:@"RattingByUser"];
                
                // Retrieve the object by id
                [query getObjectInBackgroundWithId:reviewObject.objectId
                                             block:^(PFObject *review, NSError *error) {
                                                 // Now let's update it with some new data. In this case, only cheatMode and score
                                                 review[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
                                                 review[@"MessageReview"] = _txtViewMessage.text;
                                                 review[@"bathRoomType"] = strBathRoomType;
                                                 
                                                 [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                     if(succeeded){
                                                         if([mArrayUloadPhoto count] > 0){
                                                             
                                                             [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:[_bathRoomDetail objectId]withIndex:0 withBathDetail:_bathRoomDetail];
                                                         }else{
                                                             
                                                             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                             alert.tag = 999;
                                                             [alert show];
                                                             
                                                         }
                                                         
                                                         
                                                     }else{                                                      NSString *errorString = [error userInfo][@"error"];
                                                         // Show the errorString somewhere and let the user try again.
                                                         [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                                     }
                                                     [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                                                 }];
                                             }];
            }
            else{
                [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
                
                PFObject* bathtoomRating = [PFObject objectWithClassName:@"RattingByUser"];
                bathtoomRating[@"userId"] = currentUser.objectId;
                bathtoomRating[@"userInfo"] = currentUser;
                bathtoomRating[@"userName"] = currentUser[@"name"];
                bathtoomRating[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
                bathtoomRating[@"MessageReview"] = _txtViewMessage.text;
                bathtoomRating[@"bathRoomType"] = strBathRoomType;
                bathtoomRating[@"bathRoomID"] = _strBathRoomId;
                bathtoomRating[@"bathInfo"] = _bathRoomDetail;

                [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if(succeeded){
                        if([mArrayUloadPhoto count] > 0){
                            
                            [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:[_bathRoomDetail objectId]withIndex:0 withBathDetail:_bathRoomDetail];
                        }else{
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            alert.tag = 999;
                            [alert show];
                            
                        }
                    }else{
                        NSString *errorString = [error userInfo][@"error"];
                        // Show the errorString somewhere and let the user try again.
                        [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    }
                    [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                }];
            }
            
        }
        
    } else {
        // show the signup or login screen

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
        alert.tag = 888;
        
        [alert show];
        return;
    }
    
    
}

#pragma mark-- UIImagePickerController DELEGATE
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    imageUploaded = info[UIImagePickerControllerEditedImage];
    [_btnCamera setBackgroundImage:imageUploaded forState:UIControlStateNormal];
    
    // self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark-- UIActionSheet DELEGATE
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:{
            //Camera
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
            
                if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
                {
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:picker animated:YES completion:NULL];
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"Device not supporting Camera!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
        }
            break;
        case 1:{
            //Gallery
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }
}

#pragma mark-- UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 123:{
               // [self.navigationController popToRootViewControllerAnimated:YES];
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers){
                if ([aViewController isKindOfClass:[HomeViewController class]]){
                    [self.navigationController popToViewController:aViewController animated:NO];
                }
            }
        }
            break;
        case 888:{
            if(buttonIndex == 0){
                ViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
                AppDelegate *appDelegate = [AppDelegate getInstance];
                appDelegate.strRootOrLogin = @"LoginViewController";
                
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
            break;
        case 999:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
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

#pragma mark--UICOLLECTIONVIEW DELEGATE AND DATASOURCE
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [mArrayUloadPhoto count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionUploadedImages" forIndexPath:indexPath];
    
    UIImageView *imgViewBathroom = (UIImageView *)[cell viewWithTag:888];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    
    [imgViewBathroom addGestureRecognizer:lpgr];
    
    
    //Tap Gesture
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    //doubleTapGestureRecognizer.numberOfTouchesRequired = 2;
    doubleTapGestureRecognizer.delegate = self;
    [imgViewBathroom addGestureRecognizer:doubleTapGestureRecognizer];
    
    
    //imgViewBathroom.image = [mArrayUloadPhoto objectAtIndex:indexPath.item];
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        @autoreleasepool {
            CGImageRef iref = [rep fullScreenImage];
            if (iref) {
                UIImage *image = [UIImage imageWithCGImage:iref];
                imgViewBathroom.image = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //UIMethod trigger...
                });
                iref = nil;
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
    };
    
    NSMutableDictionary *mDictUploadImage = [mArrayUloadPhoto objectAtIndex:indexPath.row];

    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:[mDictUploadImage objectForKey:@"imageURL"]
                   resultBlock:resultblock
                  failureBlock:failureblock];
    
    UIButton *btnDeleteImage = (UIButton *)[cell viewWithTag:222];
    
    [btnDeleteImage addTarget:self action:@selector(actionDeleteImage:) forControlEvents:UIControlEventTouchUpInside];
    
    btnDeleteImage.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    if([[mDictUploadImage valueForKey:@"Selected"] isEqualToString:@"YES"]){
        imgViewBathroom.layer.borderColor = [[UIColor colorWithRed:28/255.0 green:123/255.0 blue:205/255.0 alpha:1] CGColor];
        imgViewBathroom.layer.borderWidth = 2;
        btnDeleteImage.hidden = NO;
    }else{
        imgViewBathroom.layer.borderColor = [[UIColor clearColor] CGColor];
        imgViewBathroom.layer.borderWidth = 0;
        btnDeleteImage.hidden = YES;
    }
    
    return cell;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    CGPoint p = [gestureRecognizer locationInView:_collectionViewUploadImages];
    
    NSIndexPath *indexPath = [_collectionViewUploadImages indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
      
        NSLog(@"couldn't find index path =%d",(int)indexPath.item);
        
        NSMutableDictionary *mDictUploadImage = [mArrayUloadPhoto objectAtIndex:indexPath.item];
        [mDictUploadImage setValue:@"YES" forKey:@"Selected"];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
        
        [_collectionViewUploadImages reloadItemsAtIndexPaths:indexPaths];
    }
}

-(void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    CGPoint p = [tapGestureRecognizer locationInView:_collectionViewUploadImages];
    
    NSIndexPath *indexPath = [_collectionViewUploadImages indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        NSLog(@"couldn't find index path =%d",(int)indexPath.item);
        
        NSMutableDictionary *mDictUploadImage = [mArrayUloadPhoto objectAtIndex:indexPath.item];
        [mDictUploadImage setValue:@"NO" forKey:@"Selected"];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
        
        [_collectionViewUploadImages reloadItemsAtIndexPaths:indexPaths];
    }
}

-(IBAction)actionDeleteImage:(id)sender{
    
    UIButton *btn = (UIButton *) sender;
    
    [mArrayUloadPhoto removeObjectAtIndex:[btn.titleLabel.text integerValue]];
    
    [_collectionViewUploadImages reloadData];
    
    if([mArrayUloadPhoto count] == 0)
    {
        _collectionViewUploadImages.hidden = YES;
        _btnCamera.hidden = NO;
    }
}

-(void)uploadImagesOnServerWithUserId:(NSString *)userId andBathRoomID:(NSString *)bathroomId withIndex:(NSInteger)index withBathDetail:(PFObject *)bathInfo{
 
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
                            PFUser *currentUser = [PFUser currentUser];
                            bathtoomImage[@"userInfo"] = currentUser;
                            bathtoomImage[@"userId"] = userId;
                            bathtoomImage[@"bathroomID"] = bathroomId;
                            bathtoomImage[@"approve"]= @"YES";
                            bathtoomImage[@"bathInfo"]= bathInfo;

                            [bathtoomImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if(succeeded){
                                    
                                    if(blockInteger < [mArrayUloadPhoto count]-1){
                                        blockInteger++;
                                        [self uploadImagesOnServerWithUserId:userId andBathRoomID:bathroomId withIndex:blockInteger withBathDetail:bathInfo];
                                    }else{
                                        if(_requestFor == 1){
                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you for your Submission" message:@"Your location has been added successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            alert.tag = 123;
                                            [alert show];
                                        }else{
                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            alert.tag = 999;
                                            [alert show];
                                        }
                                        [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
                                    }
                                }else{
                                    NSString *errorString = [error userInfo][@"error"];
                                    // Show the errorString somewhere and let the user try again.
                                    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                }
                            }];
                        }else{
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

#pragma mark-- BATHROOM BASED ON (MALE/FEMALE/BOTH)
-(IBAction)actionBathroomBasedFor:(id)sender{
    
    if(_requestFor == 1){
        
        switch ([sender tag]) {
            case 111:{
                //Male
                _imgMale.image = [UIImage imageNamed:@"radio_button"];
                _imgFeMale.image = [UIImage imageNamed:@"unsel_radio_button"];
                _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"unsel_radio_button"];
                strBathRoomBasedOn = @"Male";
            }
                break;
            case 222:{
                //Female
                _imgMale.image = [UIImage imageNamed:@"unsel_radio_button"];
                _imgFeMale.image = [UIImage imageNamed:@"radio_button"];
                _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"unsel_radio_button"];
                strBathRoomBasedOn = @"Female";
            }
                break;
            case 333:{
                //Male and Female Both
                _imgMale.image = [UIImage imageNamed:@"unsel_radio_button"];
                _imgFeMale.image = [UIImage imageNamed:@"unsel_radio_button"];
                _imgMaleFeMaleBoth.image = [UIImage imageNamed:@"radio_button"];
                strBathRoomBasedOn = @"Both";
            }
                break;
                
            default:
                break;
        }
    }
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
    SupportViewController *supportViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"supportViewController"];
    [self.navigationController pushViewController:supportViewController animated:YES];
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
    SearchLocationViewController *searchLocationViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"searchLocationViewController"];
    [self.navigationController pushViewController:searchLocationViewController animated:YES];
}

-(IBAction)actionMyAccount:(id)sender{
    MyAccountViewController *myAccountViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"myAccountViewController"];
    [self.navigationController pushViewController:myAccountViewController animated:YES];
}


#pragma ACTION SUPPORT CLEANBM AFTER DELAY
-(IBAction)actionAddNewLocation:(id)sender{
   
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




@end
