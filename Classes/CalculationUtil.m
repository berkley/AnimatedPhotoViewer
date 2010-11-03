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
	
	return screenHeight / PHOTOHEIGHT;
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
	
	return screenHeight / PHOTOWIDTH;
}

+ (int)getScreenWidth
{
	int screenWidth = PORTRAITSCREENWIDTH;
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = LANDSCAPESCREENWIDTH;
	}
	
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
	
	return screenHeight;
}

@end
