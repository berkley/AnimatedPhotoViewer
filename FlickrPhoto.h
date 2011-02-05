//
//  FlickrPhoto.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/30/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 returned keys
 2010-11-30 17:22:31.454 AnimatedPhotoViewer[13651:307] key: height_m, obj: 500
 2010-11-30 17:22:31.455 AnimatedPhotoViewer[13651:307] key: place_id, obj: CNIOO9WbCZ4TaXVavw
 2010-11-30 17:22:31.456 AnimatedPhotoViewer[13651:307] key: accuracy, obj: 16
 2010-11-30 17:22:31.457 AnimatedPhotoViewer[13651:307] key: farm, obj: 1
 2010-11-30 17:22:31.457 AnimatedPhotoViewer[13651:307] key: isfriend, obj: 0
 2010-11-30 17:22:31.469 AnimatedPhotoViewer[13651:307] key: url_m, obj: http://farm1.static.flickr.com/196/495763445_14908240cd.jpg
 2010-11-30 17:22:31.470 AnimatedPhotoViewer[13651:307] key: height_sq, obj: 75
 2010-11-30 17:22:31.471 AnimatedPhotoViewer[13651:307] key: secret, obj: 14908240cd
 2010-11-30 17:22:31.472 AnimatedPhotoViewer[13651:307] key: width_m, obj: 375
 2010-11-30 17:22:31.473 AnimatedPhotoViewer[13651:307] key: latitude, obj: 45.553411
 2010-11-30 17:22:31.474 AnimatedPhotoViewer[13651:307] key: isfamily, obj: 0
 2010-11-30 17:22:31.484 AnimatedPhotoViewer[13651:307] key: geo_is_family, obj: 0
 2010-11-30 17:22:31.485 AnimatedPhotoViewer[13651:307] key: id, obj: 495763445
 2010-11-30 17:22:31.500 AnimatedPhotoViewer[13651:307] key: ispublic, obj: 1
 2010-11-30 17:22:31.503 AnimatedPhotoViewer[13651:307] key: longitude, obj: -122.568529
 2010-11-30 17:22:31.506 AnimatedPhotoViewer[13651:307] key: geo_is_friend, obj: 0
 2010-11-30 17:22:31.509 AnimatedPhotoViewer[13651:307] key: geo_is_public, obj: 1
 2010-11-30 17:22:31.513 AnimatedPhotoViewer[13651:307] key: width_sq, obj: 75
 2010-11-30 17:22:31.516 AnimatedPhotoViewer[13651:307] key: owner, obj: 16533212@N00
 2010-11-30 17:22:31.519 AnimatedPhotoViewer[13651:307] key: server, obj: 196
 2010-11-30 17:22:31.522 AnimatedPhotoViewer[13651:307] key: title, obj: Mad skils.
 2010-11-30 17:22:31.526 AnimatedPhotoViewer[13651:307] key: geo_is_contact, obj: 0
 2010-11-30 17:22:31.528 AnimatedPhotoViewer[13651:307] key: woeid, obj: 28288857
 2010-11-30 17:22:31.533 AnimatedPhotoViewer[13651:307] key: url_sq, obj: http://farm1.static.flickr.com/196/495763445_14908240cd_s.jpg
 */

@interface FlickrPhoto : NSObject 
{
	NSInteger photoId; //id
	NSInteger squareIconHeight; //height_sq
	NSInteger squareIconWidth; //width_sq
	NSURL *squareIconUrl; //url_sq
	CGFloat latitude; //latitude
	CGFloat longitude; //longitude
	NSString* title; //title
}

@property (nonatomic, assign) NSInteger photoId;
@property (nonatomic, assign) NSInteger squareIconHeight;
@property (nonatomic, assign) NSInteger squareIconWidth;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, retain) NSURL *squareIconUrl;
@property (nonatomic, retain) NSString* title;

- (id)initWithDict:(NSDictionary*)dict;
- (NSString*)getPath;
- (UIImageView*)getImageView;

@end
