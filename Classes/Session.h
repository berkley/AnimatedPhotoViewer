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
	NSString *flickrAuthKey;
	NSString *flickrUsername;
	NSString *flickrFullname;
	NSString *flickrNsid;
	BOOL searchMyPhotosOnly;
	NSInteger numberOfPhotos;
	NSInteger distanceThreshold;
	NSString *query;
}

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLHeading *currentHeading;
@property (nonatomic, retain) PhotoGridElementContainer *photoContainer;
@property (nonatomic, retain) NSString *flickrAuthKey;
@property (nonatomic, retain) NSString *flickrUsername;
@property (nonatomic, retain) NSString *flickrFullname;
@property (nonatomic, retain) NSString *flickrNsid;
@property (nonatomic, assign) BOOL searchMyPhotosOnly;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger distanceThreshold;
@property (nonatomic, retain) NSString *query;

+ (Session*)sharedInstance;
+ (void)inspectDictionary:(NSDictionary*)dict;
- (void)writeUserDefaults;

@end
