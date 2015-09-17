//
//  StringUtilityClass.m
//  //
//   
//

#import "StringUtilityClass.h"
#import <UIKit/UIKit.h>
//#import "Base64CodeFile.h"

@implementation StringUtilityClass

/************************************************
 Method				:	validateEmail
 Purpose			:	Email Validation
 Parameters			:	None
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	01-03-2011
 Default			:	NO
 ************************************************/ 
+(BOOL)validateEmail:(NSString*)email  
{  
	if( (0 != [email rangeOfString:@"@"].length) &&  (0 != [email rangeOfString:@"."].length) )  
	{ 	
		NSMutableCharacterSet *invalidCharSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet]mutableCopy];  
		[invalidCharSet removeCharactersInString:@"_-"];  
		NSRange range1 = [email rangeOfString:@"@" options:NSCaseInsensitiveSearch];  
		NSString *usernamePart = [email substringToIndex:range1.location];  
		NSArray *stringsArray1 = [usernamePart componentsSeparatedByString:@"."];  
		for (NSString *string in stringsArray1) 
		{	NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet: invalidCharSet];  
			if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
				return NO;  
		}  
		NSString *domainPart = [email substringFromIndex:range1.location+1];  
		NSArray *stringsArray2 = [domainPart componentsSeparatedByString:@"."];  
		for (NSString *string in stringsArray2) 
		{	NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:invalidCharSet];  
			if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])  
				return NO;  
		}  
		return YES;
	}else 
        return NO;  
}



/************************************************
 Method				:	ShowAlertMessageWithHeader
 Purpose			:	Showing Message in Alert With out Any Delegates 
 Parameters			:	Header title and Message 
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	01-03-2011
 Default			:	NO
 ************************************************/ 
+(void)ShowAlertMessageWithHeader:(NSString*)header Message:(NSString*)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:header message:message
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}


/************************************************
 Method				:	Trim
 Purpose			:	Trim ANy String from front and back   
 Parameters			:	restult String
 Return Value		:	String
 Modified By		:	Alok Patil
 Modified On		:	012-05-2012
 Default			:	NO
 ************************************************/ 
+(NSString*)Trim:(NSString*)value
{
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value;
}



/************************************************
 Method				:	convertToXMLEntities
 Purpose			:	This method avoid to send the & Operator in XML  
 Parameters			:	String  
 Return Value		:	String 
 Modified By		:	Alok Patil
 Modified On		:	01-03-2011
 Default			:	NO
 ************************************************/ 
-(NSString*)convertToXMLEntities:(NSString *) myString 
{
    NSMutableString * temp = [myString mutableCopy];
	
    [temp replaceOccurrencesOfString:@"&" withString:@"%26" options:0 range:NSMakeRange(0, [temp length])];
    //[temp replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, [temp length])];
    //[temp replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, [temp length])];
    //[temp replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, [temp length])];
    //[temp replaceOccurrencesOfString:@"'" withString:@"&apos;" options:0 range:NSMakeRange(0, [temp length])];
	
    return temp;
}



/************************************************
 Method				:	(NSRange)fromString:rangeAfterString:bySkippingNestedOpenTags:toStartOfCloseTag:
 Purpose			:	this method will retrun the range to Escaped String 
 Parameters			:	Finding string, input String, opening tag and closing tag  
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	01-03-2011
 Default			:	NO
 ************************************************/ 

+(NSRange)fromString:(NSString *)frString rangeAfterString:(NSString *)inString  bySkippingNestedOpenTags:(NSString *)openTagStr toStartOfCloseTag:(NSString *)closeTagStr
{
	size_t    strLength = [frString length];
	size_t    foundLocation = 0, tagSearchLocation = 0;
	
	int       nestedOpenTagCnt = 0;
	
	NSRange   startStrRange = NSMakeRange (0, 0);
	NSRange   endStrRange   = NSMakeRange (strLength, 0);  // if no end string, end here
	NSRange   closingSearchRange, nestedSearchRange;
	NSRange   resultRange;
	
	if (inString)  {
		startStrRange = [frString rangeOfString:inString options:0 range:NSMakeRange(0, strLength)];
		if (startStrRange.location == NSNotFound)
			return (startStrRange);	// not found
		foundLocation = NSMaxRange (startStrRange);
		tagSearchLocation = foundLocation;
		nestedOpenTagCnt = 1;
	}
	
	do  {
		closingSearchRange = NSMakeRange (foundLocation, strLength - foundLocation);
		
		if (closeTagStr)  {
			endStrRange = [frString rangeOfString:closeTagStr options:0 range:closingSearchRange];
			if (endStrRange.location == NSNotFound)
				return (endStrRange);	// not found
			nestedOpenTagCnt--;
			foundLocation = endStrRange.location + [closeTagStr length];
		}
		
		if (openTagStr)  {
			nestedSearchRange = NSMakeRange(tagSearchLocation, NSMaxRange(closingSearchRange) - tagSearchLocation);
			nestedSearchRange = [frString rangeOfString:openTagStr options:0 range:nestedSearchRange];
			if (nestedSearchRange.location != NSNotFound)  {
				nestedOpenTagCnt++;	// not found
				tagSearchLocation = nestedSearchRange.location + [openTagStr length];
			}
		}
	} while (nestedOpenTagCnt > 0);
	
	size_t  rangeLoc = startStrRange.location + [inString length];
	size_t  rangeLen = NSMaxRange (endStrRange) - rangeLoc - [closeTagStr length];
	
	resultRange = NSMakeRange (rangeLoc, rangeLen);
	
	return (resultRange);
}



/************************************************
 Method				:	removeHTMLStringFromString:
 Purpose			:	This method will remove the html code from the string and return the non-html string
 Parameters			:	Source html string  
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	01-03-2011
 Default			:	NO
 ************************************************/ 
+(NSString *)removeHTMLStringFromString:(NSString *)html {
	
	NSScanner *theScanner;
	NSString *text = nil;
	theScanner = [NSScanner scannerWithString:html];
	while ([theScanner isAtEnd] == NO) {
		// find start of tag
		[theScanner scanUpToString:@"<" intoString:NULL] ;
		// find end of tag
		[theScanner scanUpToString:@">" intoString:&text] ;
		// replace the found tag with a space
		//(you can filter multi-spaces out later if you wish)
		html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text]
											   withString:@""];
	} // while //
	html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return html;
}

/************************************************
 Method				:	SetUINavigationBarStyleWithImage:
 Purpose			:	This method will set the Image as Navigation bar 
 Parameters			:	Image name as string 
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	12-05-2012
 Default			:	NO
 ************************************************/ 
+(void)SetUINavigationBarStyleWithImage:(NSString*)strImageName
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) 
    {
        UIImage *image = [UIImage imageNamed:strImageName];
        [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

/************************************************
 Method				:	changeNavigationBackGround:
 Purpose			:	This method will set the navigation bg image in all ios..
 Parameters			:	Image name as string 
 Return Value		:	None
 Modified By		:	Dilip Patidar
 Modified On		:	10-08-2012
 Default			:	NO
 ************************************************/ 

//+(void)changeNavigationBackGround:(UINavigationBar *)navigationBar:(NSString *)imageName
//{
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5)  {
//        navigationBar.tintColor=[UIColor colorWithRed:100.0f/150.0f  green:0.0 blue:0.0 alpha:1.0f];
//        //giving error on layer.contents
//       // navigationBar.layer.contents=(id)[UIImage imageNamed:imageName].CGImage;
//    }else{
//        navigationBar.tintColor=[UIColor colorWithRed:100.0f/150.0f  green:0.0 blue:0.0 alpha:1.0f];
//        [navigationBar setBackgroundImage:[UIImage imageNamed:imageName] forBarMetrics:UIBarMetricsDefault];
//    }
//}
/************************************************
 Method				:	changeNavigation:Title:CustomFontName:
 Purpose			:	This method will set the navigation title in custom font and size and color.
 Parameters			:	NavigationItem obj,Title,Customfont name 
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	17-10-2012
 Default			:	NO
 ************************************************/ 

+(void)changeNavigation:(UINavigationItem *)navigationItem Title:(NSString *)title CustomFontName:(NSString *)fontName
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:fontName size:26];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text=title;  
    navigationItem.titleView = label;      
}

//this method return the date in format of ago system
+(NSString *)dateDiff:(NSString *)origDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *convertedDate = [df dateFromString:origDate];
    // [df release];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"never";
    } else if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else if (ti < 31536000)
    {
        int diff = round(ti / 60 / 60 / 24 / 30);
        return[NSString stringWithFormat:@"%d months ago", diff];
    }
    else{
        int diff = round(ti / 60 / 60 / 24 / 365);
        return[NSString stringWithFormat:@"%d years ago", diff];
    }
    return @"never";
    
}

//this method will return the view controller with navigation controller 
+(id)GetNavigationToViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
    return navigationController;
}

//this method will return formatted String 
+(NSString *)GetFormattedString:(NSString *)strTitle
{
    NSString *encodedString = strTitle;
    NSString *decodedString = [NSString stringWithUTF8String:[encodedString cStringUsingEncoding:[NSString defaultCStringEncoding]]];
    return decodedString;
}


+ (NSDate *)strictDateFromDate:(NSDate *)date
{
    NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:flags
                                                                   fromDate:date];
    
    NSString *stringDate = [NSString stringWithFormat:@"%ld/%ld/%ld 00:00:00 +0000", (long)components.year,(long)components.month,(long)components.day];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd hh:mm:ss +0000";
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [formatter dateFromString:stringDate];
}


+ (NSString *)formattedDateStringFromString:(NSString *)strdate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"EEE, dd MMM yyyy hh:mm:ss zzzz"];
    NSDate *date= [formatter dateFromString:strdate];
   [formatter setDateFormat: @"EEE, dd MMM YYYY"];
    NSString *strFormetedDate= [formatter stringFromDate:date];
    return strFormetedDate;
}


/************************************************
 Method				:	saveFileAtPathFileName:filename:folderName:data
 Purpose			:	This method will set the navigation title in custom font and size and color.
 Parameters			:	NavigationItem obj,Title,Customfont name
 Return Value		:	None
 Modified By		:	Alok Patil
 Modified On		:	17-10-2012
 Default			:	NO
 ************************************************/

+(BOOL)saveFileAtPathFileName:(NSString *)filename inFolder:(NSString *)folderName withData:(NSData *)data
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *folder = [NSString stringWithFormat:@"/%@",folderName];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folder];
    NSError *errorfile;
   
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&errorfile];
    
    NSString *savedAudioPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];
    
    [data writeToFile:savedAudioPath atomically:NO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:savedAudioPath])
    {
        NSLog(@"file not written");
        return NO;
    }
    return YES;
}


/************************************************
 Method				:	saveFileAtPathFileName:filename:folderName
 Purpose			:	This method will return string Flie path.
 Parameters			:	filename, folderName
 Return Value		:	string
 Modified By		:	Alok Patil
 Modified On		:	17-10-2012
 Default			:	NO
 ************************************************/

+(NSString *)GetFileAtPathFileName:(NSString *)filename inFolder:(NSString *)folderName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *folder = [NSString stringWithFormat:@"/%@",folderName];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folder];
    NSError *errorfile;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&errorfile];
    
    NSString *savedAudioPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:savedAudioPath])
    {
        NSLog(@"file not Found");
        return nil;
    }
    return savedAudioPath;
}

/*
+(NSString *)ImageToBase64:(UIImage *)image
{
    NSData *data = UIImagePNGRepresentation(image);
    NSString *base64Photo= Nil;
    if (data!=nil)
    {
        //[Base64CodeFile init];
        base64Photo = [Base64CodeFile encode:data];
    }
    return base64Photo;
}
 */


@end
