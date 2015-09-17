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


@interface AddNewLocationViewController ()<TPFloatRatingViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UzysAssetsPickerControllerDelegate,UIGestureRecognizerDelegate>
{
    UIImage *imageUploaded;
    CGFloat bathroomRating;
    NSString *strBathRoomType;
    NSMutableArray *mArrayUloadPhoto;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewUploadImages;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet TPFloatRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UITextField *txtLocationName;

@property (weak, nonatomic) IBOutlet UITextView *txtViewMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnSquat;

@property (weak, nonatomic) IBOutlet UIButton *btnSit;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;

@end

@implementation AddNewLocationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //_ratingView = [[TPFloatRatingView alloc]initWithFrame:CGRectMake(60, 133, 250, 50)];
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
    
    //Squat Bathroom
    [_btnSquat setBackgroundImage:[UIImage imageNamed:@"selected_squat_sit"] forState:UIControlStateNormal];
    [_btnSit setBackgroundImage:[UIImage imageNamed:@"unselected_squat_sit"] forState:UIControlStateNormal];
    strBathRoomType = @"Squat";
    
    mArrayUloadPhoto = [[NSMutableArray alloc] init];
    
   _collectionViewUploadImages.hidden = YES;
    
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
    } else {
        // show the signup or login screen

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CleanBM" message:@"You are not LoggedIn!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
        alert.tag = 888;
        
        [alert show];
        return;
    }
    
    [CleanBMLoader showLoader:self.navigationController withShowHideOption:YES];
    
    PFObject* bathtoomDetail = [PFObject objectWithClassName:@"BathRoomDetail"];
    
    bathtoomDetail[@"userId"] = currentUser.objectId;
    bathtoomDetail[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
    bathtoomDetail[@"description"] = _txtViewMessage.text;
    bathtoomDetail[@"bathRoomType"] = strBathRoomType;
    bathtoomDetail[@"approve"]= @"NO";
    bathtoomDetail[@"bathFullAddress"] = [[NSUserDefaults standardUserDefaults]valueForKey:@"NewLocationFullAddress"];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"AddLocationLatitude"] doubleValue] longitude:[[[NSUserDefaults standardUserDefaults]valueForKey:@"AddLocationLongitude"] doubleValue]];
    
    bathtoomDetail[@"bathLocation"] = point;
    
    [bathtoomDetail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Saved");
            
            PFObject* bathtoomRating = [PFObject objectWithClassName:@"RattingByUser"];
            
            bathtoomRating[@"userId"] = currentUser.objectId;
            bathtoomRating[@"userName"] = currentUser[@"name"];
            bathtoomRating[@"bathRating"] = [NSNumber numberWithFloat:bathroomRating];
            bathtoomRating[@"MessageReview"] = _txtViewMessage.text;
            bathtoomRating[@"bathRoomType"] = strBathRoomType;
            bathtoomRating[@"bathRoomID"] = [bathtoomDetail objectId];
            
            [bathtoomRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if(succeeded){
                    
                    if([mArrayUloadPhoto count] > 0){
                        
                        [self uploadImagesOnServerWithUserId:currentUser.objectId andBathRoomID:[bathtoomDetail objectId]withIndex:0];
                }else{
                        //BathRoom Added without Image
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your location is successfully added and waiting for approval!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
                            bathtoomImage[@"approve"]= @"NO";
                            
                            [bathtoomImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if(succeeded){
                                    
                                    if(blockInteger < [mArrayUloadPhoto count]-1)
                                    {
                                        blockInteger++;
                                        [self uploadImagesOnServerWithUserId:userId andBathRoomID:bathroomId withIndex:blockInteger];
                                    }
                                    else{
                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"CleanBM" message:@"Your location is successfully added and waiting for approval!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        alert.tag = 123;
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

@end
