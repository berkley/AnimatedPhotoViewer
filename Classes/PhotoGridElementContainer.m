//
//  PhotoGridElementContainer.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/4/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "PhotoGridElementContainer.h"


@implementation PhotoGridElementContainer

@synthesize photosKeyedByLatitude, photosKeyedByLongitude, photosByColumn, allPhotos;

- (void)addPhoto:(PhotoGridElement*)photo
{
	[allPhotos addObject:photo];
	[photosKeyedByLatitude setObject:photo forKey:[NSNumber numberWithDouble:photo.latitude]];
	[photosKeyedByLongitude setObject:photo forKey:[NSNumber numberWithDouble:photo.longitude]];
}
	 
- (void)addPhotoInColumn:(NSInteger)column row:(NSInteger)row
{
	
}

- (void)removePhoto:(PhotoGridElement*)photo
{
	
}

- (void)removePhotoByName:(NSString*)name
{
	
}

@end
