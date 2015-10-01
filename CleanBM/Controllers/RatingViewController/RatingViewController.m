//
//  RatingViewController.m
//  CleanBM
//
//  Created by Developer on 18/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "RatingViewController.h"
#import "TPFloatRatingView.h"
#import "StringUtilityClass.h"
#import <Parse/Parse.h>
#import "CleanBMLoader.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "UzysAssetsPickerController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>



@interface RatingViewController ()<TPFloatRatingViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UzysAssetsPickerControllerDelegate,UIGestureRecognizerDelegate>
{
    CGFloat bathroomRating;
    NSString *strBathRoomType;
    PFObject *reviewObject;
    BOOL isGivenRating;
    
    NSMutableArray *mArrayUloadPhoto;
    NSString *strBathRoomBasedOn;

}

@property (weak, nonatomic) IBOutlet TPFloatRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UIButton *btnSquat;
@property (weak, nonatomic) IBOutlet UIButton *btnSit;
@property (weak, nonatomic) IBOutlet UITextView *txtReviewMessage;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewUploadImages;
@property (weak, nonatomic) IBOutlet UIImageView *imgMale;
@property (weak, nonatomic) IBOutlet UIImageView *imgFeMale;
@property (weak, nonatomic) IBOutlet UIImageView *imgMaleFeMaleBoth;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;

@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    isGivenRating = NO;
    
//    PFUser *currentUser = [PFUser currentUser];
//    
//    for (PFObject *pfObject in _mArrayReviewsList) {
//        
//        if(currentUser){
//            if([currentUser.objectId isEqualToString:pfObject[@"userId"]] && [_strBathRoomId isEqualToString:pfObject[@"bathRoomID"]]){
//                reviewObject = pfObject;
//                
//                isGivenRating = YES;
//                
//                _ratingView.rating = [pfObject[@"bathRating"]floatValue];
//                
//                if([pfObject[@"bathRoomType"] isEqualToString:@"Squat"]){
//                    //Squat Bathroom
//                    [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
//                    [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
//                    strBathRoomType = @"Squat";
//                }else{
//                    //Sit Bathroom
//                    [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
//                    [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
//                    strBathRoomType = @"Sit";
//                }
//                _txtReviewMessage.text = pfObject[@"MessageReview"];
//            }
//        }
//    }
    
    //New Deve
    
    mArrayUloadPhoto = [[NSMutableArray alloc] init];

    {
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
        
        
        BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
        
        if(linkedWithFacebook || [[currentUser objectForKey:@"emailVerified"] boolValue]){
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND bathRoomID == %@",currentUser.objectId,_strBathRoomId];
            
            NSArray *filterdArray = [_mArrayReviewsList filteredArrayUsingPredicate:predicate];
            
            if(filterdArray.count > 0){
                
                PFObject *pfObject = [filterdArray firstObject];
                
                reviewObject = pfObject;
                
                isGivenRating = YES;
                
                _ratingView.rating = [pfObject[@"bathRating"]floatValue];
                
                bathroomRating = [pfObject[@"bathRating"]floatValue];
                
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
                _txtReviewMessage.text = pfObject[@"MessageReview"];
            }
        }

        
//        for (PFObject *pfObject in _mArrayReviewsList) {
//            
//            BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:currentUser];
//            
//            if(linkedWithFacebook || [[currentUser objectForKey:@"emailVerified"] boolValue]){
//                
//                if([currentUser.objectId isEqualToString:pfObject[@"userId"]] && [_strBathRoomId isEqualToString:pfObject[@"bathRoomID"]]){
//                    
//                    reviewObject = pfObject;
//                    
//                    isGivenRating = YES;
//                    
//                    _ratingView.rating = [pfObject[@"bathRating"]floatValue];
//                    
//                    bathroomRating = [pfObject[@"bathRating"]floatValue];
//                    
//                    if([pfObject[@"bathRoomType"] isEqualToString:@"Squat"]){
//                        //Squat Bathroom
//                        [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
//                        [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
//                        strBathRoomType = @"Squat";
//                    }else{
//                        //Sit Bathroom
//                        [_btnSquat setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
//                        [_btnSit setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
//                        strBathRoomType = @"Sit";
//                    }
//                    _txtReviewMessage.text = pfObject[@"MessageReview"];
//                }
//            }
//        }
    }
    
    //New Dev
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSubmitReview:(id)sender {
    
//    if ([StringUtilityClass Trim:strBathRoomType].length == 0){
//        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please select bathroom type Squat/Sit."];
//        return;
//    }
//    if ([StringUtilityClass Trim:_txtReviewMessage.text].length == 0) {
//        [StringUtilityClass ShowAlertMessageWithHeader:@"Alert" Message:@"Please enter your Comment."];
//        return;
//    }
//    
//    PFUser *currentUser = [PFUser currentUser];
//    
//    if (currentUser) {
//        // do stuff with the user
//        
//        if(isGivenRating){
//            [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
//            PFQuery *query = [PFQuery queryWithClassName:@"RattingByUser"];
//            
//            // Retrieve the object by id
//            [query getObjectInBackgroundWithId:reviewObject.objectId
//                                         block:^(PFObject *review, NSError *error) {
//                                             // Now let's update it with some new data. In this case, only cheatMode and score
//                                             review[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
//                                             review[@"MessageReview"] = _txtReviewMessage.text;
//                                             review[@"bathRoomType"] = strBathRoomType;
//                                             
//                                             [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                                                 if(succeeded){
//                                                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                                     alert.tag = 888;
//                                                     [alert show];
//                                                 }else{                                                      NSString *errorString = [error userInfo][@"error"];
//                                                     // Show the errorString somewhere and let the user try again.
//                                                     [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//                                                 }
//                                                 [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
//                                             }];
//                                         }];
//        }
//        else{
//            [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
//            
//            PFObject* bathtoomRating = [PFObject objectWithClassName:@"RattingByUser"];
//            bathtoomRating[@"userId"] = currentUser.objectId;
//            bathtoomRating[@"userName"] = currentUser[@"name"];
//            bathtoomRating[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
//            bathtoomRating[@"MessageReview"] = _txtReviewMessage.text;
//            bathtoomRating[@"bathRoomType"] = strBathRoomType;
//            bathtoomRating[@"bathRoomID"] = _strBathRoomId;
//            
//            [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                
//                if(succeeded){
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    alert.tag = 888;
//                    [alert show];
//                }else{
//                    NSString *errorString = [error userInfo][@"error"];
//                    // Show the errorString somewhere and let the user try again.
//                    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//                }
//                [CleanBMLoader showLoader:self.navigationController withShowHideOption:NO];
//            }];
//        }
//    } else {
//        // show the signup or login screen
//       
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
//        
//        alert.tag = 123;
//        
//        [alert show];
//        
//        return;
//    }

    
    
    {
        PFUser *currentUser = [PFUser currentUser];
        if(isGivenRating){
            
            [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
            PFQuery *query = [PFQuery queryWithClassName:@"RattingByUser"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:reviewObject.objectId
                                         block:^(PFObject *review, NSError *error) {
                                             // Now let's update it with some new data. In this case, only cheatMode and score
                                             review[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
                                             review[@"MessageReview"] = _txtReviewMessage.text;
                                             review[@"bathRoomType"] = strBathRoomType;
                                             
                                             [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                 if(succeeded){
                                                     if([mArrayUloadPhoto count] > 0){
                                                         
                                                         [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:[_bathRoomDetail objectId]withIndex:0 withBathDetail:_bathRoomDetail];
                                                     }else{
                                                         
                                                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                         alert.tag = 888;
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
            bathtoomRating[@"MessageReview"] = _txtReviewMessage.text;
            bathtoomRating[@"bathRoomType"] = strBathRoomType;
            bathtoomRating[@"bathRoomID"] = _strBathRoomId;
            bathtoomRating[@"bathInfo"] = _bathRoomDetail;
            
            [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    if([mArrayUloadPhoto count] > 0){
                        
                        [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:[_bathRoomDetail objectId]withIndex:0 withBathDetail:_bathRoomDetail];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag = 888;
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
}

#pragma mark RatingView delegate
- (void)floatRatingView:(TPFloatRatingView *)ratingView ratingDidChange:(CGFloat)rating{
    NSLog(@"rate value = %f", rating);
    bathroomRating = rating;
}

- (void)floatRatingView:(TPFloatRatingView *)ratingView continuousRating:(CGFloat)rating{
    NSLog(@"rate value = %f", rating);
    bathroomRating = rating;
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

#pragma mark-- UIALERT VIEW DELEGATE

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case 888:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 123:{
            if(buttonIndex == 0){
                ViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
                AppDelegate *appDelegate = [AppDelegate getInstance];
                appDelegate.strRootOrLogin = @"LoginViewController";
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
        default:
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your Review submitted successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                            alert.tag = 888;
                                            [alert show];
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


#pragma mark-- BATHROOM BASED ON (MALE/FEMALE/BOTH)
-(IBAction)actionBathroomBasedFor:(id)sender{
    
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


@end
