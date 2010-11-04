//
//  PhotoGridElement.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PhotoGridElement : UIImageView {
	CGRect offScreenPosition;
	CGRect onScreenPosition;
	NSInteger column;
	NSInteger row;
	NSInteger numColumns;
	NSInteger numRows;
	NSString *photoName;
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
}

@property (nonatomic, assign) CGRect offScreenPosition;
@property (nonatomic, assign) CGRect onScreenPosition;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger numColumns;
@property (nonatomic, assign) NSInteger numRows;
@property (nonatomic, retain) NSString *photoName;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

- (id)initWithRow:(NSInteger)r column:(NSInteger)col photoWidth:(NSInteger)pWidth 
	  photoHeight:(NSInteger)pHeight photoName:(NSString*)name lat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon;
- (void)swapFrames;

@end
