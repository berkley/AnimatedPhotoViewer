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
	int screenWidth = PORTRAITSCREENWIDTH;
	int screenHeight = PORTRAITSCREENHEIGHT;
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = LANDSCAPESCREENWIDTH;
		screenHeight = LANDSCAPESCREENHEIGHT;
	}
	
	int numrows = screenHeight / PHOTOHEIGHT;
	NSLog(@"Returning number of rows: %i", numrows);
	return numrows;
}

+ (int)getNumberOfColumns
{
	int screenWidth = PORTRAITSCREENWIDTH;
	int screenHeight = PORTRAITSCREENHEIGHT;
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = LANDSCAPESCREENWIDTH;
		screenHeight = LANDSCAPESCREENHEIGHT;
	}
	
	int numcols = screenWidth / PHOTOWIDTH;
	NSLog(@"Returning number of columns: %i", numcols);
	return numcols;
}

+ (int)getScreenWidth
{
	int screenWidth = PORTRAITSCREENWIDTH;
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = LANDSCAPESCREENWIDTH;
	}
	
	NSLog(@"returning screen width: %i", screenWidth);
	return screenWidth;
}

+ (int)getScreenHeight
{
	int screenHeight = PORTRAITSCREENHEIGHT;
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenHeight = LANDSCAPESCREENHEIGHT;
	}

	NSLog(@"returning screen height: %i", screenHeight);
	return screenHeight;
}

@end
