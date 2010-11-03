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


/*- (void)performOffScreenCalculations
{
	//for rows, postition 0 is the top of the screen, position 1 is the bottom
	//for columns, postition 0 is the left of the screen, position 1 is the right
	int offScreenColPos = 0;
	int offScreenRowPos = 0;
	int screenWidth = [CalculationUtil getScreenWidth];
	int screenHeight = [CalculationUtil getScreenHeight];
	
	if(self.column > self.numColumns / 2)
	{
		offScreenColPos = 1;
	}
	
	if(self.row > self.numRows / 2)
	{
		offScreenRowPos = 1;
	}
	
	NSLog(@"offScreen Quadrant: %i, %i", offScreenRowPos, offScreenColPos);

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
}*/

- (void)performOffScreenCalculations
{
	int screenWidth = [CalculationUtil getScreenWidth];
	int screenHeight = [CalculationUtil getScreenHeight];

	int offScreenColPos = OFFSCREENNEGOFFSET;
	int offScreenRowPos = OFFSCREENNEGOFFSET;
	
	float colsOver2 = self.numColumns / 2;
	NSLog(@"=======================================");
	NSLog(@"row: %i, col: %i", self.row, self.column);
	NSLog(@"col: %i numColumns/2: %f", self.column, colsOver2);
	if(self.column >= colsOver2)
	{
		offScreenColPos = screenHeight + OFFSCREENPOSOFFSET;
	}
	float rowsOver2 = self.numRows / 2;
	NSLog(@"numRows: %i numRows/2: %f", self.numRows, rowsOver2);
	if(self.row + 1 > rowsOver2)
	{
		offScreenRowPos = screenWidth + OFFSCREENPOSOFFSET;
	}
	
	NSLog(@"OffScreenPos: %i, %i", offScreenRowPos, offScreenColPos);
	
	int x = (screenWidth / self.numColumns) * self.column + offScreenColPos;
	int y = (screenHeight / self.numRows) * self.row + offScreenRowPos;
	self.offScreenPosition = CGRectMake(x, y, 0, 0);
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
	if(self = [super initWithImage:[UIImage imageNamed:name]])
    {
		self.column = col;
		self.row = r;
		self.numColumns = [CalculationUtil getNumberOfColumns];
		self.numRows = [CalculationUtil getNumberOfRows];
		self.photoName = name;
		[self performOffScreenCalculations];
		[self performOnScreenCalculations];
	}
	return self;
}

- (void)swapFrames
{
	if(self.frame.origin.x == self.onScreenPosition.origin.x &&
	   self.frame.origin.y == self.onScreenPosition.origin.y)
	{
		[self performOffScreenCalculations];
		[self performOnScreenCalculations];
		self.frame = self.offScreenPosition;
	}
	else 
	{
		[self performOffScreenCalculations];
		[self performOnScreenCalculations];
		self.frame = self.onScreenPosition;
	}
}

@end
