//
//  Constant.h
//  CleanBM
//
//  Created by Developer on 23/07/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

#ifndef CleanBM_Constant_h
#define CleanBM_Constant_h

#define kNotificationSearchLocation @"SearchLocation"


typedef enum
{
    NEARMELOCATION = 1,
    ADVANCESEARCH = 2,
    ROOTVIEWCONTROLLER = 3,
    LOGINVIEWCNTROLLER = 4
}requestfor;


#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IPHONE_6 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )667 ) < DBL_EPSILON )

#define IS_IPHONE_6_PLUS ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )736 ) < DBL_EPSILON )

#define serviceURL @"http://123.176.35.7/"

#if !defined(MIN)
#define MIN(A,B)((A) < (B) ? (A) : (B))
#endif

#if !defined(MAX)
#define MAX(A,B)((A) > (B) ? (A) : (B))
#endif


#define COLOR_COMPONENT_SCALE_FACTOR 255.0f

#define DEFAULT_TITLE_COLOR [UIColor colorWithRed:16 / COLOR_COMPONENT_SCALE_FACTOR green:30 / COLOR_COMPONENT_SCALE_FACTOR blue:61 / COLOR_COMPONENT_SCALE_FACTOR alpha:1.0f];



#endif
