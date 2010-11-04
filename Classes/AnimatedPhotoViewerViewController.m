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
#import "Session.h"
#import "GridView.h"

@implementation AnimatedPhotoViewerViewController

@synthesize elevationGrid;

BOOL exploded = NO;
NSArray *photoGridCols;
BOOL photoViewLoaded = NO;
UIView *photoContainerView;
SM3DAR_Controller *sm3dar;

- (void) addGridAtX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    // Create point.
    SM3DAR_Fixture *p = [[SM3DAR_Fixture alloc] init];
    
    Coord3D coord = {
        x, y, z
    };
    
    p.worldPoint = coord;
	
    GridView *gridView = [[GridView alloc] init];
	
    // Give the point a view.
    gridView.point = p;
    p.view = gridView;
    [gridView release];
    
    // Add point to 3DAR scene.
    [sm3dar addPointOfInterest:p];
    [p release];
}

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
			//NSLog(@"adding photo %@", [photoArr objectAtIndex:photoArrIndex]);
			NSString *line = [photoArr objectAtIndex:photoArrIndex];
			NSArray *photoProps = [line componentsSeparatedByString:@","];
			NSString *name = [photoProps objectAtIndex:0];
			NSString *lat = [photoProps objectAtIndex:1];
			NSString *lon = [photoProps objectAtIndex:2];
			//NSLog(@"photo info: %@, %@, %@", name, lat, lon);
			PhotoGridElement *gridElement = [[PhotoGridElement alloc] initWithRow:i column:j 
											photoWidth:PHOTOWIDTH photoHeight:PHOTOHEIGHT 
											photoName:name lat:[lat floatValue] lon:[lon floatValue]];
			//NSLog(@"adding gridElement %@ at onScreenPosition (%f, %f)", gridElement.photoName, 
			//	  gridElement.onScreenPosition.origin.x, gridElement.onScreenPosition.origin.y);
			//NSLog(@"adding gridElement %@ at offScreenPosition (%f, %f)", gridElement.photoName, 
			//	  gridElement.offScreenPosition.origin.x, gridElement.offScreenPosition.origin.y);
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

//explode the photos views
- (void)changePhotoViews
{
	//NSLog(@"photoGridCols count: %i", [photoGridCols count]);
	for(int i=0; i<[photoContainerView.subviews count]; i++)
	{
		UIView *subview = [photoContainerView.subviews objectAtIndex:i];
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

//release all PhotoGridElement views and the photoContainerView
- (void)resetPhotoViews
{
	if(photoGridCols != nil)
	{  //make sure we release all of the current views before re-initing them
		for(int i=0; i<[photoGridCols count]; i++)
		{
			NSArray *photoGridRows = (NSArray*)[photoGridCols objectAtIndex:i];
			for(int j=0; j<[photoGridRows count]; j++)
			{
				PhotoGridElement *photoElement = (PhotoGridElement*)[photoGridRows objectAtIndex:j];
				[photoElement removeFromSuperview];
				[photoElement release];
			}
		}
	}
	[photoContainerView removeFromSuperview];
	[photoContainerView release];
}

- (void)initViews
{
	NSArray *photoArr = [self getPhotoArray];
	
	photoGridCols = [self createGridWithPhotos:photoArr];
	if(photoContainerView != nil)
	{
		[photoContainerView release];
	}
	photoContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [CalculationUtil getScreenWidth], [CalculationUtil getScreenHeight])];
	[photoContainerView setBackgroundColor:[UIColor blackColor]];
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	
	swipeRecognizer.delegate = self;
	[photoContainerView addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	
	tapRecognizer.delegate = self;
	[photoContainerView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	
	//NSLog(@"photoGridCols count: %i", [photoGridCols count]);
	for(int i=0; i<[photoGridCols count]; i++)
	{
		NSArray *photoGridRows = (NSArray*)[photoGridCols objectAtIndex:i];
		for(int j=0; j<[photoGridRows count]; j++)
		{
			PhotoGridElement *photoElement = (PhotoGridElement*)[photoGridRows objectAtIndex:j];
			//NSLog(@"image %i, %i: %@", i, j, photoElement.photoName);
			photoElement.frame = photoElement.offScreenPosition;
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDuration:ANIMATIONDURATION];
			[photoContainerView addSubview:photoElement];
			photoElement.frame = photoElement.onScreenPosition;
			[UIView commitAnimations];
		}
	}
	[self.view addSubview:photoContainerView];
	exploded = NO;
	photoViewLoaded = YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	NSLog(@"View did load");	
	photoViewLoaded = YES;
	//operationQueue = [[NSOperationQueue alloc] init];
	//[[Session sharedInstance].motionManager startGyroUpdatesToQueue:operationQueue withHandler:self]
	
	sm3dar = [SM3DAR_Controller sharedController];
	sm3dar.delegate = self;
	sm3dar.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	[self.view addSubview:sm3dar.view];
	self.elevationGrid = [[[ElevationGrid alloc] initFromFile:@"elevation_grid_25km_100s.txt"] autorelease];
	[self addGridAtX:0 Y:0 Z:-80];
	photoViewLoaded = NO;
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[sm3dar.view addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	[sm3dar suspend];
	sm3dar.view.hidden = YES;
	
	self.view.backgroundColor = [UIColor blackColor];
	
	[self initViews];
}

- (void)switchSubviews
{
	NSString *pvl = @"FALSE";
	if(photoViewLoaded)
		pvl = @"TRUE";
	
	NSLog(@"switching subviews...photoViewLoaded is %@", pvl);
	if(photoViewLoaded)
	{
		NSLog(@"loading 3dar");
		[self changePhotoViews];
		photoContainerView.hidden = YES;
		[sm3dar resume];
		sm3dar.view.hidden = NO;
		photoViewLoaded = NO;
		//[photoContainerView setHidden:YES];
		//photoViewLoaded = NO;
	}
	else 
	{
		NSLog(@"loading photo view");
		photoContainerView.hidden = NO;
		[sm3dar suspend];
		sm3dar.view.hidden = YES;
		[self changePhotoViews];
		photoViewLoaded = YES;
		//[sm3dar suspend];
		//[photoContainerView setHidden:NO];
		//photoViewLoaded = YES;
	}

}

- (void)handleTap:(id)caller
{
	NSLog(@"tap");
	[self changePhotoViews];
}

- (void)handleSwipe:(id)caller
{
	NSLog(@"swipe");
	
	[self switchSubviews];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if(photoViewLoaded)
	{
		return YES;		
	}
	return NO;

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	
	if(!exploded)
	{
		[self changePhotoViews];
	}
	[self performSelector:@selector(changeOrientation:) withObject:self afterDelay:1];
}

- (void)changeOrientation:(id)caller
{
	if(photoViewLoaded)
	{
		[self resetPhotoViews];
		[self initViews];	
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"!!!!!!!!!!!!WARNING: DID RECEIVE MEMORY WARNING!!!!!!!!!!!!");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	NSLog(@"!!!!!!!!!!!!!!!!View Did Unload!!!!!!!!!!!!!!!!!!!!!!!!");
}


- (void)dealloc {
    [super dealloc];
}

@end
