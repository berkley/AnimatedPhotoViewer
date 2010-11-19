//
//  ControlOverlayViewController.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/17/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "ControlOverlayViewController.h"
#import "CalculationUtil.h"

@implementation ControlOverlayViewController

@synthesize animatedPhotoViewerViewController;

UIImageView *backgroundImageView;
UIButton *minusButton;
CGRect onScreenRect;
CGRect offScreenRect;
double screenWidth;
double screenHeight;

- (id)init
{
	if(self = [super init])
	{
		[self setScreenSizesAndRects];
	}
	return self;
}

- (void) setScreenSizesAndRects
{
	screenWidth = [CalculationUtil getScreenWidth];
	screenHeight = [CalculationUtil getScreenHeight];
	onScreenRect = CGRectMake(10, 10, screenWidth - 20, screenHeight - 20);
	offScreenRect = CGRectMake(screenWidth + 1000, 0, screenWidth, screenHeight);
	NSLog(@"screenWidth: %f", screenWidth);
	minusButton.frame = CGRectMake(screenWidth - 80, 20, 40, 40);
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.view.alpha = .5;

	//backgroundImageView = [[UIImageView alloc] initWithFrame:onScreenRect];
	//backgroundImageView.image = [UIImage imageNamed:@"ControlPanelBar.png"];
	
	//add the minus button
	minusButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 80, 20, 40, 40)];
	minusButton.showsTouchWhenHighlighted = YES;
	UIImage *minusButtonImage = [UIImage imageNamed:@"MinusButton.png"];
	[minusButton setImage:minusButtonImage forState:UIControlStateNormal];
	[minusButton addTarget:self action:@selector(minusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:minusButton];	
	//[self.view addSubview:backgroundImageView];
	self.view.hidden = NO;
}

- (void)minusButtonTouched:(id)sender
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:ANIMATIONDURATION];
	[self setRectOffScreen];
	[UIView commitAnimations];	
	self.animatedPhotoViewerViewController.plusButton.hidden = NO;
	[self.view removeFromSuperview];
	[self.animatedPhotoViewerViewController controlOverlayDidExit];
}

- (void)setRectOffScreen
{
	[self setScreenSizesAndRects];
	self.view.frame = offScreenRect;
}

- (void)setRectOnScreen
{
	[self setScreenSizesAndRects];
	self.view.frame = onScreenRect;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[minusButton release];
}

- (void)dealloc 
{
    [super dealloc];
}


@end
