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
#import "PhotoGridElementContainer.h"
#import "math.h"
#import "Flickr.h"
#import "ControlOverlayViewController.h"

@implementation AnimatedPhotoViewerViewController

@synthesize elevationGrid, plusButton;;

BOOL exploded = NO;
NSArray *photoGridCols;
BOOL photoViewLoaded = NO;
UIView *photoContainerView;
SM3DAR_Controller *sm3dar;
NSMutableDictionary *poiDict;
NSTimer *motionTimer;
CLLocationManager *locationManager;


//add the 3dar grid
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
											photoName:name lat:[lat doubleValue] lon:[lon doubleValue]];
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

//get the photos and lat/lons from the photos.txt file
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

//explode/implode the photos views
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
	if(photoContainerView != nil)
	{
		[photoContainerView removeFromSuperview];
		[photoContainerView release];
		photoContainerView = nil;
	}
}

//set the photo view to receive messages from the accelerometer (iff photoViewLoaded)
- (void)setAccellerometerDelegate
{
    if(photoViewLoaded)
	{
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0/kAccelerometerFrequency)];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	}
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
	
	//add swipe recognizer
	swipeRecognizer.delegate = self;
	[photoContainerView addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	
	//add tap recognizer
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
	[self setAccellerometerDelegate];
	
	//add the plus button
	double screenWidth = [CalculationUtil getScreenWidth];
	double screenHeight = [CalculationUtil getScreenHeight];
	plusButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 50, screenHeight - 50, 40, 40)];
	plusButton.showsTouchWhenHighlighted = YES;
	UIImage *plusButtonImage = [UIImage imageNamed:@"PlusButton.png"];
	[plusButton setImage:plusButtonImage forState:UIControlStateNormal];
	[plusButton addTarget:self action:@selector(plusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:plusButton];	
}

- (void)init3dar
{
	sm3dar = [SM3DAR_Controller sharedController];
	sm3dar.delegate = self;
	sm3dar.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	[self.view addSubview:sm3dar.view];
	self.elevationGrid = [[[ElevationGrid alloc] initFromFile:@"elevation_grid_25km_100s.txt"] autorelease];
	[self addGridAtX:0 Y:0 Z:-80];
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[sm3dar.view addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	//[sm3dar startCamera];
	[sm3dar suspend];
	sm3dar.view.hidden = YES;
}

/*- (void)motionTimerFired:(NSTimer*)timer
{
	//NSLog(@"timer fired");
	CMAccelerometerData *motion = [Session sharedInstance].motionManager.accelerometerData;
	NSLog(@"yaw: %f pitch: %f roll: %f", motion.acceleration.y, motion.acceleration.x, motion.acceleration.z);
}*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	NSLog(@"View did load");	
	if([Session sharedInstance].flickrAuthKey == nil)
	{  //need to authenticate
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Flickr" 
							  message:@"You need to authorize this app to use your Flickr account.  Safari will open and you will be brought back to the app after you finish the process." 
							  delegate:self 
							  cancelButtonTitle:@"Cancel" 
							  otherButtonTitles:@"Ok", nil];
		[alert show];
		[alert release];
		alert = nil;
	}
	[Session sharedInstance].currentOrientation = UIInterfaceOrientationPortrait;
	//uncomment and change this for accelerometer support
	//motionTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(motionTimerFired:) userInfo:nil repeats:YES];
	//NSRunLoop *runner = [NSRunLoop currentRunLoop];
	//[runner addTimer:motionTimer forMode: NSDefaultRunLoopMode];

	//[Session sharedInstance].motionManager.accelerometerUpdateInterval = 1;
	//[[Session sharedInstance].motionManager startAccelerometerUpdates];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.headingFilter = 10.0;
	[locationManager startUpdatingHeading];
	[locationManager startUpdatingLocation];
	locationManager.delegate = self;
	
	[self init3dar];
	
	photoViewLoaded = NO;
	self.view.backgroundColor = [UIColor blackColor];
	
	[self initViews];
}

- (void)plusButtonTouched:(id)sender
{
	ControlOverlayViewController *covc = [[ControlOverlayViewController alloc] init];
	[self.view addSubview:covc.view];
	covc.animatedPhotoViewerViewController = self;
	//[covc release];
	plusButton.hidden = YES;
}

//handle alert view feedback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		[[Flickr sharedInstance] openAuthUrl];
	}
}

- (void)addPhotosTo3darGrid
{
	NSLog(@"Adding photos to the 3dar view");
	if(poiDict == nil)
	{
		poiDict = [[NSMutableDictionary alloc] init];
		for(int i=0; i<[photoGridCols count]; i++)
		{
			NSArray *photoGridRows = (NSArray*)[photoGridCols objectAtIndex:i];
			for(int j=0; j<[photoGridRows count]; j++)
			{
				PhotoGridElement *photoElement = (PhotoGridElement*)[photoGridRows objectAtIndex:j];
				SM3DAR_Point *point = [sm3dar initPointOfInterestWithLatitude:photoElement.latitude 
																	longitude:photoElement.longitude 
																	 altitude:0 
																		title:photoElement.photoName
																	 subtitle:@"test"
															  markerViewClass:[SM3DAR_IconMarkerView class] 
																   properties:nil];
				photoElement.frame = CGRectMake(0, 0, 72, 72);
				SM3DAR_IconMarkerView *iconMarkerView = [[SM3DAR_IconMarkerView alloc] initWithFrame:photoElement.frame];
				iconMarkerView.icon = photoElement;
				point.view = iconMarkerView;
				iconMarkerView.point = point;
				[poiDict setObject:point forKey:photoElement.photoName];
			}
		}
		
		[sm3dar addPointsOfInterest:[poiDict allValues]];
	}
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
		[sm3dar startCamera];
		sm3dar.view.hidden = NO;
		photoViewLoaded = NO;
		[self addPhotosTo3darGrid];
	}
	else 
	{
		NSLog(@"loading photo view");
		photoContainerView.hidden = NO;
		[sm3dar suspend];
		sm3dar.view.hidden = YES;
		[self resetPhotoViews];
		[self initViews];
		photoViewLoaded = YES;
		[self setAccellerometerDelegate];
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

//rotate the photo views
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	
	if(!exploded)
	{
		[self changePhotoViews];
	}
	[Session sharedInstance].currentOrientation = toInterfaceOrientation;
	[self performSelector:@selector(changeOrientation:) withObject:self afterDelay:1];
}

/*- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(fromInterfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[sm3dar.view removeFromSuperview];
		[sm3dar forceRelease];
		sm3dar = nil;
		sm3dar = [SM3DAR_Controller reinit];
		[self init3dar];
		NSLog(@"setting 3dar size to width: %i, height: %i", [CalculationUtil getScreenWidth], [CalculationUtil getScreenHeight]);
		sm3dar.view.frame = CGRectMake(0, 0, [CalculationUtil getScreenWidth], [CalculationUtil getScreenHeight]);
		[sm3dar removeAllPointsOfInterest];
		[self addGridAtX:0 Y:0 Z:-80];		
		if(!photoViewLoaded)
		{
			sm3dar.view.hidden = NO;
		}
	}
}*/

//recalculate the photos views when the orientation changes
- (void)changeOrientation:(id)caller
{
	if(photoViewLoaded)
	{
		[self resetPhotoViews];
		[self initViews];	
	}
}

//change the view when the user pitches the device up
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	//NSLog(@"y: %f x: %f z: %f", acceleration.y, acceleration.x, acceleration.z);
	/*[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	if([Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeLeft ||
	   [Session sharedInstance].currentOrientation == UIInterfaceOrientationLandscapeRight)
	{
		if(acceleration.x < -0.9)
		{
			[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
			[self switchSubviews];
		}
	}
	else 
	{
		if(acceleration.y < -0.9)
		{
			[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
			[self switchSubviews];
		}
	}*/
}

- (void)updatePhotosForNewHeading
{
	CLLocation *here = [Session sharedInstance].currentLocation;
	double degrees = 30.0;
	
	//test location in the middle of portland
	//CLLocation *here = [[CLLocation alloc] initWithLatitude:45.5 longitude:-122.5];
	
	CLHeading *dir = [Session sharedInstance].currentHeading;
	double leftBound = dir.trueHeading;
	double rightBound = dir.trueHeading;	
	
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
	
	CLLocationCoordinate2D leftcoord = [CalculationUtil pointOnCircle:1.0 angleInDegrees:leftBound originx:here.coordinate.longitude originy:here.coordinate.latitude];
	CLLocationCoordinate2D rightcoord = [CalculationUtil pointOnCircle:1.0 angleInDegrees:rightBound originx:here.coordinate.longitude originy:here.coordinate.latitude];
	NSLog(@"leftcoord: lat: %f lon: %f", leftcoord.latitude, leftcoord.longitude);
	NSLog(@"rightcoord: lat: %f lon: %f", rightcoord.latitude, rightcoord.longitude);	
	
	CLLocation *rightBoundingPoint = [[CLLocation alloc] initWithLatitude:rightcoord.latitude longitude:rightcoord.longitude];
	CLLocation *leftBoundingPoint = [[CLLocation alloc] initWithLatitude:leftcoord.latitude longitude:leftcoord.longitude];
	
	NSArray *vertices = [NSArray arrayWithObjects:here, leftBoundingPoint, rightBoundingPoint, nil];
	
	NSLog(@"bounding points are: (%f,%f) (%f,%f) (%f,%f)", here.coordinate.longitude, here.coordinate.latitude, 
		  leftBoundingPoint.coordinate.longitude, leftBoundingPoint.coordinate.latitude,
		  rightBoundingPoint.coordinate.longitude, rightBoundingPoint.coordinate.latitude);
	NSLog(@"here is: %f,%f", here.coordinate.longitude, here.coordinate.latitude);
	
	for(int i=0; i<[photoGridCols count]; i++)
	{
		NSArray *photoGridRows = (NSArray*)[photoGridCols objectAtIndex:i];
		for(int j=0; j<[photoGridRows count]; j++)
		{ 	//check if the photos is in the polygon [(here.coordinate.lon, here.coordinate.lat), (lbpLon, lbpLat), (rbpLon, rbpLat)]
			PhotoGridElement *photoElement = (PhotoGridElement*)[photoGridRows objectAtIndex:j];
			CLLocation *location = [[CLLocation alloc] initWithLatitude:photoElement.latitude longitude:photoElement.longitude];
			//NSLog(@"photo location: %f, %f", photoElement.longitude, photoElement.latitude);
			BOOL isInPoly = [CalculationUtil pnpoly:vertices location:location];
			//NSLog(@"is in poly: %i", isInPoly);
			if(isInPoly)
			{  //the photo should be displayed
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
				[UIView setAnimationDuration:ANIMATIONDURATION];
				photoElement.alpha = 1.0;
				[UIView commitAnimations];
			}
			else 
			{  //photo should not be displayed
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
				[UIView setAnimationDuration:ANIMATIONDURATION];
				photoElement.alpha = 0.0;
				[UIView commitAnimations];
			}
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//NSLog(@"location updated: lat: %f lon: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	[Session sharedInstance].currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	NSLog(@"heading updated: mag: %f true: %f", newHeading.magneticHeading, newHeading.trueHeading);
	[Session sharedInstance].currentHeading = newHeading;
	[self updatePhotosForNewHeading];
}

//3dar delegate method that does the opposite of the above method
-(void)didChangeOrientationYaw:(CGFloat)yaw pitch:(CGFloat)pitch roll:(CGFloat)roll
{
	NSLog(@"3dar orientation change: yaw %f pitch %f roll %f", yaw, pitch, roll);
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
	[motionTimer invalidate];
}

- (void)dealloc {
    [super dealloc];
}

@end
