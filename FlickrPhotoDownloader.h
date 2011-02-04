//
//  FlickrPhotoDownloader.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 12/1/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

@interface FlickrPhotoDownloader : NSOperation {
	FlickrPhoto *photo;
	NSString *cacheLocation;
}

@property (nonatomic, retain) FlickrPhoto *photo;
@property (nonatomic, retain) NSString *cacheLocation;

- (id)initWithPhoto:(FlickrPhoto*)flickrPhoto writeLocation:(NSString*)cacheLoc;


@end
