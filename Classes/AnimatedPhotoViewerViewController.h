//
//  AnimatedPhotoViewerViewController.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/2/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CMMotionManager.h>
#import "SM3DAR.h"
#import "ElevationGrid.h"

@interface AnimatedPhotoViewerViewController : UIViewController 
  <UIGestureRecognizerDelegate, SM3DAR_Delegate, UIAccelerometerDelegate, CLLocationManagerDelegate> 
{
	ElevationGrid *elevationGrid;
	UIButton *plusButton;
}

@property (nonatomic, retain) ElevationGrid *elevationGrid;
@property (nonatomic, retain) UIButton *plusButton;

@end

