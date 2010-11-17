//
//  Session.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionManager.h>
#import <CoreLocation/CoreLocation.h>
#import "PhotoGridElementContainer.h"

@interface Session : NSObject {
	CMMotionManager *motionManager;
	UIInterfaceOrientation currentOrientation;
	CLLocation *currentLocation;
	CLHeading *currentHeading;
	PhotoGridElementContainer *photoContainer;
}

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLHeading *currentHeading;
@property (nonatomic, retain) PhotoGridElementContainer *photoContainer;

+ (Session*)sharedInstance;

@end
