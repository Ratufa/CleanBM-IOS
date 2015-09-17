//
//  SupportViewController.m
//  CleanBM
//
//  Created by Developer on 06/08/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#import "SupportViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface SupportViewController ()<UIWebViewDelegate,MFMailComposeViewControllerDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIWebView *webViewSupport;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIVewController;
@property (weak, nonatomic) IBOutlet UIButton *btnSupport;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;

@end

@implementation SupportViewController

#pragma mark-- VIEW LIFE CYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Webview Load URL
   // NSString *strUrl = @"http://www.cleanbm.com/support";
    //[_activityIVewController startAnimating];
    //[_webViewSupport loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark-- ACTION BACK
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark--WEBVIEW DELEGATE
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //[_activityIVewController stopAnimating];
    //_activityIVewController.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    //[_activityIVewController stopAnimating];
   // _activityIVewController.hidden = YES;
}

-(IBAction)actionSupportLink:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.cleanbm.com/support"]];
}

-(IBAction)actionEmail:(id)sender{
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"CleanBM Support"];
    //[controller setMessageBody:@"Hello there." isHTML:NO];
    
    [controller setToRecipients:@[@"attendant@cleanbm.com"]];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark-- MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
