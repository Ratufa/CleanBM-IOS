//
//  Annotation.m
//  CustomAnnotation
//
//  Created by Ratufa Technologies on 19/12/14.
//  Copyright (c) 2014 Ratufa Technologies. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize locationType;



- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate; 
}

@end
