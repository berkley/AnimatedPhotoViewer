//
//  ControlOverlayViewController.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/17/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimatedPhotoViewerViewController.h"

@interface ControlOverlayViewController : UIViewController 
{
	AnimatedPhotoViewerViewController *animatedPhotoViewerViewController;
}

@property (nonatomic, retain) AnimatedPhotoViewerViewController *animatedPhotoViewerViewController;

@end
