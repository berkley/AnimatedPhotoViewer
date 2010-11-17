//
//  PhotoGridElementContainer.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/4/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhotoGridElement.h"

@interface PhotoGridElementContainer : NSObject {
	NSMutableDictionary *photosKeyedByLatitude;
	NSMutableDictionary *photosKeyedByLongitude;
	NSMutableArray *photosByColumn;
	NSMutableArray *allPhotos;
}

@property (nonatomic, retain) NSMutableDictionary *photosKeyedByLatitude;
@property (nonatomic, retain) NSMutableDictionary *photosKeyedByLongitude;
@property (nonatomic, retain) NSMutableArray *photosByColumn;
@property (nonatomic, retain) NSMutableArray *allPhotos;

- (void)addPhoto:(PhotoGridElement*)photo;
- (void)removePhoto:(PhotoGridElement*)photo;
- (void)removePhotoByName:(NSString*)name;

@end
