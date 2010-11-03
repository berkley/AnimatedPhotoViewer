//
//  PhotoGridElement.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "PhotoGridElement.h"

#define OFFSCREENPOSOFFSET     512
#define OFFSCREENNEGOFFSET     -512
#define PORTRAITSCREENWIDTH    768
#define PORTRAITSCREENHEIGHT   1024
#define LANDSCAPESCREENHEIGHT  768
#define LANDSCAPESCREENWIDTH   1024

@implementation PhotoGridElement

@synthesize offScreenPosition, onScreenPosition;


- (void)performOffScreenCalculations
{
	//postition 0 is the top of the screen, position 1 is the bottom
	int offScreenColPos = 0;
	int offScreenRowPos = 0;
	int screenWidth = PORTRAITSCREENWIDTH;
	int screenHeight = PORTRAITSCREENHEIGHT;
	if([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ||
	   [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)
	{
		screenWidth = LANDSCAPESCREENWIDTH;
		screenHeight = LANDSCAPESCREENHEIGHT;
	}
	
	if(column > numColumns / 2)
	{
		offScreenColPos = 1;
	}
	
	if(row > numRows / 2)
	{
		offScreenRowPos = 1;
	}

	//set the off screen position to one of the 4 corners
	if(offScreenRowPos == 0 && offScreenColPos == 0)
	{
		self.offScreenPosition = CGRectMake(OFFSCREENNEGOFFSET, OFFSCREENNEGOFFSET, 0, 0);
	}
	else if(offScreenRowPos == 1 && offScreenColPos == 0)
	{
		self.offScreenPosition = CGRectMake(screenWidth	+ OFFSCREENPOSOFFSET, OFFSCREENNEGOFFSET, 0, 0);
	}
	else if(offScreenRowPos == 0 && offScreenColPos == 1)
	{
		self.offScreenPosition = CGRectMake(OFFSCREENNEGOFFSET, screenHeight + OFFSCREENPOSOFFSET, 0, 0);
	}
	else if(offScreenRowPos == 1 && offScreenColPos == 1)
	{
		self.offScreenPosition = CGRectMake(screenWidth	+ OFFSCREENPOSOFFSET, screenHeight + OFFSCREENPOSOFFSET, 0, 0);
	}
}

- (id)initWithRow:(NSInteger)r column:(NSInteger)col numRows:(NSInteger)numrows numCols:(NSInteger)numcols
{
	if(self = [super init])
    {
		col = col;
		row = r;
		numColumns = numcols;
		numRows = numrows;
		[self performOffScreenCalculations];
	}
	return self;
}

@end
