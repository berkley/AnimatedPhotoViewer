//
//  AnimatedPhotoViewerViewController.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/2/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "AnimatedPhotoViewerViewController.h"
#import "PhotoGridElement.h"

@implementation AnimatedPhotoViewerViewController

//CMMotionManager *motionManager;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

//create a 2d grid of PhotoGridElements with start positions for each photo
- (NSArray*)createGridWithPhotos:(NSArray*)photoArr rows:(NSInteger)rows cols:(NSInteger)cols
{
	NSMutableArray *rowArr = [[NSMutableArray alloc] initWithCapacity:rows];
	for(int i=0; i<rows; i++)
	{
		NSMutableArray *colArr = [[NSMutableArray alloc] initWithCapacity:cols];
		int photoArrIndex = 0;
		for(int j=0; j<cols; j++)
		{
			PhotoGridElement *gridElement = [[PhotoGridElement alloc] initWithRow:i column:j numRows:rows numCols:cols];
			[colArr addObject:gridElement];
			photoArrIndex++;
			if(photoArrIndex == [photoArr count])
			{ //if we get to the end of the photos, stop and return
				break;
			}
		}
		[rowArr addObject:colArr];
	}
	
	return rowArr;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//motionManager = [CMMotionManager alloc
	
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
	NSLog(@"View did load");
	int rowcount = 0;
	for(int i=0; i<[photoArr count]; i++)
	{
		//[self createAndLayoutViewForPhoto:[photoArr objectAtIndex:i] withNumberOfPhotos:[photoArr count]];
		NSLog(@"image %i: %@", i, [photoArr objectAtIndex:i]);
		NSString *photoName = (NSString*)[photoArr objectAtIndex:i];
		UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:photoName]];
		int y = 0;
		if(i*256 >= 1024)
		{
			y = 1;
		}
		if(i*256 >= 2048)
		{
			y = 2;
		}
		
		NSLog(@"y: %i  i*256: %i", y, i*256);
		NSLog(@"adding image at %i, %i, 256, 256", (i*256) % 1024, y * 256);
		CGRect endRect = CGRectMake((i*256) % 1024, y * 256, 256, 256);
		
		int x = 0;
		if(y == 0)
		{
			y = -256;
			x = (i*256) % 1024;
			if(x < 512)
				x -= 256;
			else 
				x += 256;
		}
		if(y == 1)
		{
			y = y * 256;
			x = -256;
			if(rowcount == 2 || rowcount == 3)
				x = 1024 + 256;
		}
		if(y == 2)
		{
			y = 1024;
			x = (i*256) % 1024;
			if(x < 512)
				x -= 256;
			else 
				x += 256;
		}
			
		CGRect startRect = CGRectMake(x, y, 256, 256);
		view.frame = startRect;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:.5];
		[self.view addSubview:view];
		view.frame = endRect;
		[UIView commitAnimations];
		[view release];
		
		rowcount++;
		if(rowcount > 3)
		{
			rowcount = 0;
		}
	}
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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
