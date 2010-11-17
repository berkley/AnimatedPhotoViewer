//
//  CalculationUtil.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "CalculationUtil.h"

@implementation CalculationUtil

+ (int)getNumberOfRows
{
	int screenWidth = [self getScreenWidth];
	int screenHeight = [self getScreenHeight];
	if([Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeLeft ||
	   [Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = [self getScreenWidth];
		screenHeight = [self getScreenHeight];;
	}
	
	int numrows = screenHeight / PHOTOHEIGHT;
	//NSLog(@"Returning number of rows: %i", numrows);
	return numrows;
}

+ (int)getNumberOfColumns
{
	int screenWidth = [self getScreenWidth];
	int screenHeight = [self getScreenHeight];;
	if([Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeLeft ||
	   [Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = [self getScreenWidth];
		screenHeight = [self getScreenHeight];;
	}
	
	int numcols = screenWidth / PHOTOWIDTH;
	//NSLog(@"Returning number of columns: %i", numcols);
	return numcols;
}

+ (int)getScreenWidth
{
	int screenWidth = [[UIScreen mainScreen] bounds].size.width;
	int screenHeight = [[UIScreen mainScreen] bounds].size.height;
	if([Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeLeft ||
	   [Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = screenHeight;
	}
	
	//NSLog(@"returning screen width: %i", screenWidth);
	return screenWidth;
}

+ (int)getScreenHeight
{
	int screenWidth = [[UIScreen mainScreen] bounds].size.width;
	int screenHeight = [[UIScreen mainScreen] bounds].size.height;
	if([Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeLeft ||
	   [Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeRight)
	{
		screenHeight = screenWidth;
	}

	//screenHeight = [[UIScreen mainScreen] bounds].size.height;
	//NSLog(@"returning screen height: %i", screenHeight);
	return screenHeight;
}

+ (BOOL)pnpoly:(NSArray*)vertices location:(CLLocation*)loc
{
	//original C code: 
	/*
	 int pnpoly(int nvert, float *vertx, float *verty, float testx, float testy)
	 {
	 int i, j, c = 0;
	 for (i = 0, j = nvert-1; i < nvert; j = i++) {
	 if ( ((verty[i]>testy) != (verty[j]>testy)) &&
	 (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
	 c = !c;
	 }
	 return c;
	 }
	 */
	int nvert = [vertices count];
	double testx = loc.coordinate.longitude;
	double testy = loc.coordinate.latitude;
	//NSLog(@"textx: %f, testy: %f", testx, testy);
	
	int i, j, c = 0;
	for (i = 0, j = nvert-1; i < nvert; j = i++) 
	{
		CLLocation *nextLocJ = [vertices objectAtIndex:j];
		CLLocation *nextLocI = [vertices objectAtIndex:i];
		double vertyi = nextLocI.coordinate.latitude;
		double vertyj = nextLocJ.coordinate.latitude;
		double vertxi = nextLocI.coordinate.longitude;
		double vertxj = nextLocJ.coordinate.longitude;
		//NSLog(@"vertyi: %f vertyj: %f vertxi: %f vertxj: %f", vertyi, vertyj, vertxi, vertxj);
		if ( ((vertyi>testy) != (vertyj>testy)))
		{
			/*NSLog(@"test 1 passed");
			NSLog(@"testx: %f", testx);
			NSLog(@"(vertxj-vertxi) * (testy-vertyi): %f", (vertxj-vertxi) * (testy-vertyi));
			NSLog(@"(vertyj-vertyi) + vertxi: %f", (vertyj-vertyi) + vertxi);
			NSLog(@"(vertxj-vertxi) * (testy-vertyi) / (vertyj-vertyi) + vertxi: %f", (vertxj-vertxi) * (testy-vertyi) / (vertyj-vertyi) + vertxi);*/
			if((testx < (vertxj-vertxi) * (testy-vertyi) / (vertyj-vertyi) + vertxi))
			{
				//NSLog(@"test 2 passed");
				//NSLog(@"changing c to %i", !c);
				c = !c;
			}
		}
	}
	
	if(c > 0)
		return YES;
	else 
		return NO;
}

+ (double)toRadians:(double)degrees
{
	return degrees * (PI / 180.0);
}

+ (void)testPnpoly
{
	CLLocation *loc = [[CLLocation alloc] initWithLatitude:-4.0 longitude:-1.0];
	CLLocation *p1 = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
	CLLocation *p2 = [[CLLocation alloc] initWithLatitude:-10.0 longitude:0.0];
	CLLocation *p3 = [[CLLocation alloc] initWithLatitude:-10.0 longitude:-10.0];
	NSMutableArray *verts = [[NSMutableArray alloc] initWithObjects:p1, p2, p3, nil];
	int inPoly = [self pnpoly:verts location:loc];
	NSLog(@"inPoly: %i", inPoly);
}

+ (CLLocationCoordinate2D)pointOnCircle:(double)radius angleInDegrees:(double)angleInDegrees originx:(double)originx originy:(double)originy
{
	// Convert from degrees to radians via multiplication by PI/180        
	NSLog(@"computing point on line starting at (%f, %f) with heading %f and length %f", originx, originy, angleInDegrees, radius);
	double radsx = angleInDegrees * (PI / 180.0);
	double radsy = angleInDegrees * (PI / 180.0);
	double x = (double)(radius * sin(radsx)) + originx;
	double y = (double)(radius * cos(radsy)) + originy;
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = y;
	coordinate.longitude = x;
	return coordinate;
}

+ (void)testTriangleCreation
{
	//CLLocation *here = [Session sharedInstance].currentLocation;
	double degrees = 30;
	
	
	CLLocation *here = [[CLLocation alloc] initWithLatitude:45.5 longitude:-122.5];
	//CLLocation *here = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
	//CLHeading *dir = [Session sharedInstance].currentHeading;
	//double leftBound = dir.trueHeading;
	//double rightBound = dir.trueHeading;	
	double leftBound = 180;
	double rightBound = 180;
	
	//60 degree view portal
	leftBound = leftBound - degrees;
	if(leftBound < 0)
	{
		leftBound = leftBound + 360;
	}
	
	rightBound = rightBound + degrees;
	if(rightBound >= 360)
	{
		rightBound = rightBound - 360;
	}
	
	CLLocationCoordinate2D leftcoord = [CalculationUtil pointOnCircle:0.25 angleInDegrees:leftBound originx:here.coordinate.longitude originy:here.coordinate.latitude];
	CLLocationCoordinate2D rightcoord = [CalculationUtil pointOnCircle:0.25 angleInDegrees:rightBound originx:here.coordinate.longitude originy:here.coordinate.latitude];
	NSLog(@"leftcoord: lat: %f lon: %f", leftcoord.latitude, leftcoord.longitude);
	NSLog(@"rightcoord: lat: %f lon: %f", rightcoord.latitude, rightcoord.longitude);	
	
	CLLocation *rightBoundingPoint = [[CLLocation alloc] initWithLatitude:rightcoord.latitude longitude:rightcoord.longitude];
	CLLocation *leftBoundingPoint = [[CLLocation alloc] initWithLatitude:leftcoord.latitude longitude:leftcoord.longitude];
		
	NSLog(@"bounding points are: (%f,%f) (%f,%f) (%f,%f)", here.coordinate.latitude, here.coordinate.longitude, 
		  leftBoundingPoint.coordinate.latitude, leftBoundingPoint.coordinate.longitude,
		  rightBoundingPoint.coordinate.latitude, rightBoundingPoint.coordinate.longitude);
	NSLog(@"here is: %f,%f", here.coordinate.longitude, here.coordinate.latitude);
	
}

@end
