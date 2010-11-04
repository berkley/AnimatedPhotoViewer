//
//  AnimatedPhotoViewerViewController.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/2/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SM3DAR.h"
#import "ElevationGrid.h"

@interface AnimatedPhotoViewerViewController : /*SM3DAR_Controller*/UIViewController <UIGestureRecognizerDelegate, SM3DAR_Delegate> 
{
	ElevationGrid *elevationGrid;
}

@property (nonatomic, retain) ElevationGrid *elevationGrid;

@end

