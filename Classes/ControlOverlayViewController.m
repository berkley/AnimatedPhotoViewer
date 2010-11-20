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


CGRect onScreenRect;
CGRect offScreenRect;
double screenWidth;
double screenHeight;

//input objects
UIButton *minusButton; //x button
UISlider *distanceSlider;
UISlider *numberPhotosSlider;
UISwitch *myPhotosSwitch;
UISwitch *useCurrentLocationSwitch;
UITextField *searchTextField;

//labels
UILabel *distanceLabel;
UILabel *numberPhotosLabel;
UILabel *myPhotosLabel;
UILabel *useCurrentLocationLabel;

- (id)init
{
	if(self = [super init])
	{
		[self setScreenSizesAndRects];
	}
	return self;
}

- (void)layoutUIElements
{
	minusButton.frame = CGRectMake(screenWidth - 70, 10, 40, 40);
	searchTextField.frame = CGRectMake(10, 60, screenWidth - 40, 30);
	
	distanceLabel.frame = CGRectMake(searchTextField.frame.origin.x + 5, 
									 searchTextField.frame.origin.y + searchTextField.frame.size.height + 10, 
									 (screenWidth - 40)/2 - 10, 
									 30);
	distanceSlider.frame = CGRectMake(searchTextField.frame.origin.x + distanceLabel.frame.size.width + 10, 
									  searchTextField.frame.origin.y + searchTextField.frame.size.height + 10, 
									  (screenWidth - 40) / 2 - 10, 
									  30);
	
	numberPhotosLabel.frame = CGRectMake(searchTextField.frame.origin.x + 5, 
										 distanceLabel.frame.origin.y + distanceLabel.frame.size.height + 10, 
										 (screenWidth - 40)/2 - 10, 
										 30);
	numberPhotosSlider.frame = CGRectMake(searchTextField.frame.origin.x + distanceLabel.frame.size.width + 10, 
										  distanceSlider.frame.origin.y + distanceSlider.frame.size.height + 10, 
										  (screenWidth - 40) / 2 - 10, 
										  30);
	
	myPhotosLabel.frame = CGRectMake(searchTextField.frame.origin.x + 5, 
									 numberPhotosLabel.frame.origin.y + numberPhotosLabel.frame.size.height + 10, 
									 (screenWidth - 40)/2 - 10, 
									 30);
	myPhotosSwitch.frame = CGRectMake(searchTextField.frame.origin.x + distanceLabel.frame.size.width + 10, 
									  numberPhotosSlider.frame.origin.y + numberPhotosSlider.frame.size.height + 10, 
									  (screenWidth - 40) / 2 - 10, 
									  30);
}

- (void) setScreenSizesAndRects
{
	screenWidth = [CalculationUtil getScreenWidth];
	screenHeight = [CalculationUtil getScreenHeight];
	onScreenRect = CGRectMake(10, 10, screenWidth - 20, screenHeight - 20);
	offScreenRect = CGRectMake(screenWidth + 1000, 0, screenWidth, screenHeight);
	NSLog(@"screenWidth: %f", screenWidth);
	[self layoutUIElements];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.view.alpha = .9;
	
	//add the minus button
	minusButton = [[UIButton alloc] init];
	minusButton.showsTouchWhenHighlighted = YES;
	UIImage *minusButtonImage = [UIImage imageNamed:@"MinusButton.png"];
	[minusButton setImage:minusButtonImage forState:UIControlStateNormal];
	[minusButton addTarget:self action:@selector(minusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		
	//text field
	searchTextField = [[UITextField alloc] init];
	searchTextField.placeholder = @"Search Terms";
	searchTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
	searchTextField.borderStyle = UITextBorderStyleRoundedRect;
	searchTextField.alpha = 1.0;
	searchTextField.returnKeyType = UIReturnKeyDone;
	searchTextField.delegate = self;
	if([Session sharedInstance].query != nil)
	{
		searchTextField.text = [Session sharedInstance].query;
	}
	
	//distance slider
	distanceLabel = [[UILabel alloc] init];
	distanceLabel.text = @"Distance";
	distanceLabel.alpha = .8;
	distanceLabel.backgroundColor = [UIColor clearColor];
	distanceSlider = [[UISlider alloc] init];
	distanceSlider.minimumValue = 1.0;
	distanceSlider.maximumValue = 10.0;
	distanceSlider.alpha = .8;
	[distanceSlider addTarget:self action:@selector(distanceValueUpdated:) forControlEvents:UIControlEventValueChanged];
	distanceSlider.value = [Session sharedInstance].distanceThreshold;
	
	//number of photos slider
	numberPhotosLabel = [[UILabel alloc] init];
	numberPhotosLabel.text = @"Photo Size";
	numberPhotosLabel.alpha = .8;
	numberPhotosLabel.backgroundColor = [UIColor clearColor];
	numberPhotosSlider = [[UISlider alloc] init];
	numberPhotosSlider.minimumValue = 20.0;
	numberPhotosSlider.maximumValue = 200.0;
	numberPhotosSlider.alpha = .8;
	[numberPhotosSlider addTarget:self action:@selector(numberPhotosValueUpdated:) forControlEvents:UIControlEventValueChanged];
	numberPhotosSlider.value = [Session sharedInstance].numberOfPhotos;
	
	//my photos switch
	myPhotosLabel = [[UILabel alloc] init];
	myPhotosLabel.text = @"My Photos Only";
	myPhotosLabel.alpha = .8;
	myPhotosLabel.backgroundColor = [UIColor clearColor];
	myPhotosSwitch = [[UISwitch alloc] init];
	myPhotosSwitch.alpha = .8;
	[myPhotosSwitch addTarget:self action:@selector(myPhotosSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
	if([Session sharedInstance].searchMyPhotosOnly)
	{
		myPhotosSwitch.on = YES;
	}
	
	[self layoutUIElements];
	[self.view addSubview:myPhotosSwitch];
	[self.view addSubview:myPhotosLabel];
	[self.view addSubview:numberPhotosSlider];
	[self.view addSubview:numberPhotosLabel];
	[self.view addSubview:distanceSlider];
	[self.view addSubview:distanceLabel];
	[self.view addSubview:searchTextField];
	[self.view addSubview:minusButton];	
	self.view.hidden = NO;
}

- (void)distanceValueUpdated:(id)sender
{
	[Session sharedInstance].distanceThreshold = distanceSlider.value;
}

- (void)numberPhotosValueUpdated:(id)sender
{
	[Session sharedInstance].numberOfPhotos = numberPhotosSlider.value;
}
													
- (void)myPhotosSwitchFlipped:(id)sender
{
	[Session sharedInstance].searchMyPhotosOnly = NO;
	if(myPhotosSwitch.on)
	{
		[Session sharedInstance].searchMyPhotosOnly = YES;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[Session sharedInstance].query = textField.text;
}

- (void)minusButtonTouched:(id)sender
{
	[searchTextField resignFirstResponder];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:ANIMATIONDURATION];
	[self setRectOffScreen];
	[UIView commitAnimations];	
	self.animatedPhotoViewerViewController.plusButton.hidden = NO;
	[self.animatedPhotoViewerViewController controlOverlayDidExit];
	[[Session sharedInstance] writeUserDefaults];
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
	[distanceSlider release];
	[numberPhotosSlider release];
	[myPhotosSwitch release];
	[useCurrentLocationSwitch release];
	[searchTextField release];
	[distanceLabel release];
	[numberPhotosLabel release];
	[myPhotosLabel release];
	[useCurrentLocationLabel release];
}

- (void)dealloc 
{
    [super dealloc];
	[minusButton release];
	[distanceSlider release];
	[numberPhotosSlider release];
	[myPhotosSwitch release];
	[useCurrentLocationSwitch release];
	[searchTextField release];
	[distanceLabel release];
	[numberPhotosLabel release];
	[myPhotosLabel release];
	[useCurrentLocationLabel release];
}


@end
