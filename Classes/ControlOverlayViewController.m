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

UIView *controllerBarView;
UIButton *minusButton;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	double screenWidth = [CalculationUtil getScreenWidth];
	double screenHeight = [CalculationUtil getScreenHeight];
	CGRect offscreenMainRect = CGRectMake(screenWidth + 100, screenHeight - 120, screenWidth - 20, 100);
	CGRect mainRect = CGRectMake(10, screenHeight - 120, screenWidth - 20, 100);
	controllerBarView = [[UIView alloc] initWithFrame:mainRect];
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:mainRect];
	backgroundImageView.image = [UIImage imageNamed:@"ControlPanelBar.png"];
	[controllerBarView addSubview:backgroundImageView];
	
	//add the minus button
	minusButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 50, screenHeight - 50, 40, 40)];
	minusButton.showsTouchWhenHighlighted = YES;
	UIImage *minusButtonImage = [UIImage imageNamed:@"MinusButton.png"];
	[minusButton setImage:minusButtonImage forState:UIControlStateNormal];
	[minusButton addTarget:self action:@selector(minusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:minusButton];	
	[self.view addSubview:backgroundImageView];

	//self.view.frame = offscreenMainRect;
	/*[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:ANIMATIONDURATION];
	self.view.frame = mainRect;
	[UIView commitAnimations];*/
}

- (void)minusButtonTouched:(id)sender
{
	double screenWidth = [CalculationUtil getScreenWidth];
	double screenHeight = [CalculationUtil getScreenHeight];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:ANIMATIONDURATION];
	
	self.view.frame = CGRectMake(screenWidth + 100, screenHeight - 120, screenWidth - 20, 100);
	//self.view.hidden = YES;
	[UIView commitAnimations];	
	self.animatedPhotoViewerViewController.plusButton.hidden = NO;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
