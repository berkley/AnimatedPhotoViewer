//
//  AnimatedPhotoViewerViewController.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/2/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "AnimatedPhotoViewerViewController.h"
#import "PhotoGridElement.h"
#import "Constants.h"
#import "CalculationUtil.h"

@implementation AnimatedPhotoViewerViewController

@synthesize elevationGrid;

BOOL exploded = NO;
NSArray *photoGridCols;



//create a 2d grid of PhotoGridElements with start positions for each photo
- (NSArray*)createGridWithPhotos:(NSArray*)photoArr
{
	int rows = [CalculationUtil getNumberOfRows];
	int cols = [CalculationUtil getNumberOfColumns];
	NSMutableArray *rowArr = [[NSMutableArray alloc] initWithCapacity:rows];
	BOOL done = NO;
	int photoArrIndex = 0;
	for(int i=0; i<rows; i++)
	{
		NSMutableArray *colArr = [[NSMutableArray alloc] initWithCapacity:cols];
		for(int j=0; j<cols; j++)
		{
			NSLog(@"adding photo %@", [photoArr objectAtIndex:photoArrIndex]);
			NSString *line = [photoArr objectAtIndex:photoArrIndex];
			NSArray *photoProps = [line componentsSeparatedByString:@","];
			NSString *name = [photoProps objectAtIndex:0];
			NSString *lat = [photoProps objectAtIndex:1];
			NSString *lon = [photoProps objectAtIndex:2];
			NSLog(@"photo info: %@, %@, %@", name, lat, lon);
			PhotoGridElement *gridElement = [[PhotoGridElement alloc] initWithRow:i column:j 
											photoWidth:PHOTOWIDTH photoHeight:PHOTOHEIGHT 
											photoName:name lat:[lat floatValue] lon:[lon floatValue]];
			NSLog(@"adding gridElement %@ at onScreenPosition (%f, %f)", gridElement.photoName, 
				  gridElement.onScreenPosition.origin.x, gridElement.onScreenPosition.origin.y);
			NSLog(@"adding gridElement %@ at offScreenPosition (%f, %f)", gridElement.photoName, 
				  gridElement.offScreenPosition.origin.x, gridElement.offScreenPosition.origin.y);
			[colArr addObject:gridElement];
			photoArrIndex++;
			if(photoArrIndex == [photoArr count])
			{ //if we get to the end of the photos, stop and return
				done = YES;
				break;
			}
		}
		[rowArr addObject:colArr];
		if(done)
		{
			break;
		}
	}
	
	return rowArr;
}

- (NSArray*) getPhotoArray
{
	NSError *error;
	NSString *filename = @"photos.txt";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
	[fileManager copyItemAtPath:defaultDBPath toPath:dataPath error:&error];
	NSString *photos = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
	NSArray *photoArr = [photos componentsSeparatedByString:@"\n"];
	return photoArr;
}

- (void)changeViews
{
	NSLog(@"photoGridCols count: %i", [photoGridCols count]);
	for(int i=0; i<[self.view.subviews count]; i++)
	{
		UIView *subview = [self.view.subviews objectAtIndex:i];
		if([subview isKindOfClass:[PhotoGridElement class]])
		{
			PhotoGridElement *element = (PhotoGridElement*)subview;
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDuration:ANIMATIONDURATION];
			[element swapFrames];
			[UIView commitAnimations];
		}
	}
	if(exploded)
		exploded = NO;
	else 
		exploded = YES;
	

}

- (void)initViews
{
	NSArray *photoArr = [self getPhotoArray];
	photoGridCols = [self createGridWithPhotos:photoArr];
	
	NSLog(@"photoGridCols count: %i", [photoGridCols count]);
	for(int i=0; i<[photoGridCols count]; i++)
	{
		NSArray *photoGridRows = (NSArray*)[photoGridCols objectAtIndex:i];
		for(int j=0; j<[photoGridRows count]; j++)
		{
			PhotoGridElement *photoElement = (PhotoGridElement*)[photoGridRows objectAtIndex:j];
			NSLog(@"image %i, %i: %@", i, j, photoElement.photoName);
			photoElement.frame = photoElement.offScreenPosition;
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDuration:ANIMATIONDURATION];
			[self.view addSubview:photoElement];
			photoElement.frame = photoElement.onScreenPosition;
			[UIView commitAnimations];
		}
	}
	exploded = NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//motionManager = [CMMotionManager alloc
	NSLog(@"View did load");	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	
	swipeRecognizer.delegate = self;
	[self.view addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	
	tapRecognizer.delegate = self;
	[self.view addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	
	[self initViews];
}

- (void)removeAllSubviews
{
	int count = [self.view.subviews count];
	for(int i=0; i<count; i++)
	{
		NSLog(@"view: %i", i);
		UIView *subview = [self.view.subviews objectAtIndex:0];
		if([subview isKindOfClass:[PhotoGridElement class]])
		{
			[subview removeFromSuperview];
			[subview release];
		}
	}
}

- (void)handleTap:(id)caller
{
	NSLog(@"tap");
	[self changeViews];
}

- (void)handleSwipe:(id)caller
{
	NSLog(@"swipe");
	//load 3dar view
	[self removeAllSubviews];
	sm3dar = [SM3DAR_Controller sharedController];
    sm3dar.delegate = self;
    sm3dar.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    self.view = sm3dar.view;
	self.elevationGrid = [[[ElevationGrid alloc] initFromFile:@"elevation_grid_25km_100s.txt"] autorelease];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	
	if(!exploded)
	{
		[self changeViews];
	}
	[self performSelector:@selector(changeOrientation:) withObject:self afterDelay:1];
}

- (void)changeOrientation:(id)caller
{
	[self removeAllSubviews];
	[self initViews];	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
