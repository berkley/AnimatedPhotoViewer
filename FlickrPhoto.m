//
//  FlickrPhoto.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/30/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "FlickrPhoto.h"


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

@end
