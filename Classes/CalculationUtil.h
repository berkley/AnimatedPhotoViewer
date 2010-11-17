//
//  CalculationUtil.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Session.h"

@interface CalculationUtil : NSObject {

}

+ (int)getScreenHeight;
+ (int)getScreenWidth;
+ (int)getNumberOfColumns;
+ (int)getNumberOfRows;
+ (BOOL)pnpoly:(NSArray*)vertices location:(CLLocation*)loc;
+ (double)toRadians:(double)degrees;
+ (void)testTriangleCreation;
+ (CLLocationCoordinate2D)pointOnCircle:(double)radius angleInDegrees:(double)angleInDegrees originx:(double)originx originy:(double)originy;

@end
