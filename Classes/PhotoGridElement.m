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

@synthesize offScreenPosition, onScreenPosition, photoName, column, row, numColumns, numRows, latitude, longitude;

- (void)performOffScreenCalculations
{
	int screenWidth = [CalculationUtil getScreenWidth];
	int screenHeight = [CalculationUtil getScreenHeight];

	int offScreenColPos = OFFSCREENNEGOFFSET;
	int offScreenRowPos = OFFSCREENNEGOFFSET;
	
	float colsOver2 = self.numColumns / 2;
	//NSLog(@"=======================================");
	//NSLog(@"row: %i, col: %i", self.row, self.column);
	//NSLog(@"col: %i numColumns/2: %f", self.column, colsOver2);
	if(self.column >= colsOver2)
	{
		offScreenColPos = screenHeight + OFFSCREENPOSOFFSET;
	}
	float rowsOver2 = self.numRows / 2;
	//NSLog(@"numRows: %i numRows/2: %f", self.numRows, rowsOver2);
	if(self.row + 1 > rowsOver2)
	{
		offScreenRowPos = screenWidth + OFFSCREENPOSOFFSET;
	}
	
	//NSLog(@"OffScreenPos: %i, %i", offScreenRowPos, offScreenColPos);
	
	int x = (screenWidth / self.numColumns) * self.column + offScreenColPos;
	int y = (screenHeight / self.numRows) * self.row + offScreenRowPos;
	self.offScreenPosition = CGRectMake(x, y, 0, 0);
}

- (void)performOnScreenCalculations
{
	int cellWidth = PHOTOWIDTH;
	int cellHeight = PHOTOHEIGHT;
	self.onScreenPosition = CGRectMake(column * cellWidth, row * cellHeight, PHOTOWIDTH, PHOTOHEIGHT);
}

- (id)initWithRow:(NSInteger)r column:(NSInteger)col photoWidth:(NSInteger)pWidth 
	  photoHeight:(NSInteger)pHeight photoName:(NSString*)name lat:(CGFloat)lat lon:(CGFloat)lon
{
	if(self = [super initWithImage:[UIImage imageNamed:name]])
    {
		self.column = col;
		self.row = r;
		self.numColumns = [CalculationUtil getNumberOfColumns];
		self.numRows = [CalculationUtil getNumberOfRows];
		self.photoName = name;
		self.latitude = lat;
		self.longitude = lon;
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
