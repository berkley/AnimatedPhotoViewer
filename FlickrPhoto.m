//
//  FlickrPhoto.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/30/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "FlickrPhoto.h"
#import "Session.h"

@implementation FlickrPhoto

@synthesize photoId, squareIconHeight, squareIconWidth, latitude, longitude, squareIconUrl, title;

//init with the dict that is returned from the Flickr class
- (id)initWithDict:(NSDictionary*)dict
{
	if(self = [super init])
	{
		//fill out all of the fields from the dictionary
		self.photoId = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]] intValue];
		self.squareIconHeight = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"height_sq"]] intValue];
		self.squareIconWidth = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"width_sq"]] intValue];
		self.latitude = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"latitude"]] floatValue];
		self.longitude = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"longitude"]] floatValue];
		self.squareIconUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [dict objectForKey:@"url_sq"]]];
		self.title = [NSString stringWithFormat:@"%@", [dict objectForKey:@"title"]];
	}
	return self;
}

//return an image view.  Note that the photo must be downloaded first before you can do this.
- (UIImageView*)getImageView
{
	NSLog(@"getting imageView for photo with id %i", self.photoId);
	NSString *photoPath = [self getPath];
	NSLog(@"creating imageView with photo at path %@", photoPath);
	UIImage *photoImage = [[UIImage alloc] initWithContentsOfFile:[self getPath]];
	UIImageView *photoImageView = [[UIImageView alloc] initWithImage:photoImage];
	[photoImage release];
	return photoImageView;
}

- (NSString*)getPath
{
//	NSMutableArray *pathComponents = [[NSMutableArray alloc] initWithObjects:[Session sharedInstance].cachePath, [NSString stringWithFormat:@"%i",self.photoId], nil];
	NSMutableArray *pathComponents = [[NSMutableArray alloc] init];
	[pathComponents addObject:[Session sharedInstance].cachePath];
	[pathComponents addObject:[NSString stringWithFormat:@"%i", self.photoId]];
	NSString *photoPath = [NSString pathWithComponents:pathComponents];
	NSLog(@"photo path is %@", photoPath);
	return photoPath;
}

@end
