//
//  FlickrPhotoDownloader.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 12/1/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "FlickrPhotoDownloader.h"
#import "Constants.h"

@implementation FlickrPhotoDownloader

@synthesize photo, cacheLocation;

- (id)initWithPhoto:(FlickrPhoto*)flickrPhoto writeLocation:(NSString*)cacheLoc
{
	if(self = [super init])
	{
		NSLog(@"initialized a photo downloader");
		self.photo = flickrPhoto;
		self.cacheLocation = cacheLoc;
	}
	return self;
}

- (void)start
{
	NSLog(@"writing photo data to cache for image %@", [NSString stringWithFormat:@"%i", self.photo.photoId]);
	NSData *photoData = [NSData dataWithContentsOfURL:self.photo.squareIconUrl];
	[photoData writeToFile:self.cacheLocation atomically:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:PHOTOWRITTEN object:[NSString stringWithFormat:@"%i", self.photo.photoId]];
	//[photoData release];
}

@end
