//
//  PhotoGridElement.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "PhotoGridElement.h"
#import "Constants.h"
#import "CalculationUtil.h"

@implementation PhotoGridElement

@synthesize offScreenPosition, onScreenPosition, photoName, column, row, numColumns, numRows;


- (void)performOffScreenCalculations
{
	//postition 0 is the top of the screen, position 1 is the bottom
	int offScreenColPos = 0;
	int offScreenRowPos = 0;
	int screenWidth = [CalculationUtil getScreenWidth];
	int screenHeight = [CalculationUtil getScreenHeight];
	
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

- (void)performOnScreenCalculations
{
	int screenWidth = [CalculationUtil getScreenWidth];
	int screenHeight = [CalculationUtil getScreenHeight];

	NSLog(@"screenWidth: %i, numColumns: %i", screenWidth, numColumns);
	NSLog(@"screenHeight: %i, numRows: %i", screenHeight, numRows);
	//int cellWidth = screenWidth / numColumns;
	//int cellHeight = screenHeight / numRows;
	int cellWidth = PHOTOWIDTH;
	int cellHeight = PHOTOHEIGHT;
	NSLog(@"cellWidth: %i  cellHeight: %i", cellWidth, cellHeight);
	self.onScreenPosition = CGRectMake(column * cellWidth, row * cellHeight, PHOTOWIDTH, PHOTOHEIGHT);
}

- (id)initWithRow:(NSInteger)r column:(NSInteger)col photoWidth:(NSInteger)pWidth photoHeight:(NSInteger)pHeight photoName:(NSString*)name;
{
	if(self = [super init])
    {
		int screenWidth = [CalculationUtil getScreenWidth];
		int screenHeight = [CalculationUtil getScreenHeight];
		
		self.column = col;
		self.row = r;
		self.numColumns = screenWidth / pWidth;
		self.numRows = screenHeight / pHeight;
		self.photoName = name;
		[self performOffScreenCalculations];
		[self performOnScreenCalculations];
	}
	return self;
}

@end
