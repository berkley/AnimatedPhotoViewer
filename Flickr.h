//
//  Flickr.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/16/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveFlickr.h"

/*Flickr key
 Key: 06878e5364a281e7ccdc5b5f8f85e57e
 Secret: 2095762ff1a7b481
 Your authentication URL is http://www.flickr.com/auth-72157619852874490
 */

@interface Flickr : NSObject <OFFlickrAPIRequestDelegate>
{
	NSString *apikey;
	NSString *secret;
	OFFlickrAPIContext *context;
}

@property (nonatomic, retain, readonly) NSString *apikey;
@property (nonatomic, retain, readonly) NSString *secret;
@property (nonatomic, retain, readonly) OFFlickrAPIContext *context;

+ (Flickr*)sharedInstance;
- (void)openAuthUrl;
- (void)getAuthToken:(NSString*)frob;
- (void)searchFlickr;

@end
