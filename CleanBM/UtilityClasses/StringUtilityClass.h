//
//  StringUtilityClass.h
//
//
//     
//

#import <Foundation/Foundation.h>


@interface StringUtilityClass : NSObject {

}

//ValidateEmail will check your email string and validate it.
+(BOOL)validateEmail:(NSString*)email;		//default return value NO

//This method used to show Alert With delegete Nil 
+(void)ShowAlertMessageWithHeader:(NSString*)header Message:(NSString*)message;

//this method will retrun the range to Escaped String 
+(NSRange)fromString:(NSString *)inString rangeAfterString:(NSString *)inString  bySkippingNestedOpenTags:(NSString *)openTagStr toStartOfCloseTag:(NSString *)closeTagStr;

//This method will remove the html code from the string and return the non-html string
+(NSString *)removeHTMLStringFromString:(NSString *)html;

//Trim ANy String from front and back
+(NSString*)Trim:(NSString*)value;

//This method will set the Image as Navigation bar 
+(void)SetUINavigationBarStyleWithImage:(NSString*)strImageName;

//This method will set the navigation bg image in all ios..
//+(void)changeNavigationBackGround:(UINavigationBar *)navigationBar :(NSString *)imageName;
//
//
//+(void)changeNavigation:(UINavigationItem *)navigationItem Title:(NSString *)title CustomFontName:(NSString *)fontName;
//
////this method return the date in format of ago system
//+(NSString *)dateDiff:(NSString *)origDate;
//
////this method will return the view controller with navigation controller
//+(id)GetNavigationToViewController:(UIViewController *)viewController;

//this method will return formatted String
+(NSString *)GetFormattedString:(NSString *)strTitle;

+ (NSDate *)strictDateFromDate:(NSDate *)date;

+ (NSString *)formattedDateStringFromString:(NSString *)strdate;

    //+(NSString *)ImageToBase64:(UIImage *)image;

+(BOOL)saveFileAtPathFileName:(NSString *)filename inFolder:(NSString *)folderName withData:(NSData *)data;

+(NSString *)GetFileAtPathFileName:(NSString *)filename inFolder:(NSString *)folderName;

@end
