//
//  CalculationUtil.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "CalculationUtil.h"
#import "Constants.h"

@implementation CalculationUtil

+ (int)getNumberOfRows
{
	int screenWidth = [self getScreenWidth];
	int screenHeight = [self getScreenHeight];
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
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
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
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
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
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
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = screenWidth;
	}

	screenHeight = [[UIScreen mainScreen] bounds].size.height;
	//NSLog(@"returning screen height: %i", screenHeight);
	return screenHeight;
}

@end
