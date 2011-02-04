//
//  PhotoCache.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/30/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

@interface PhotoCache : NSObject {

}

+ (PhotoCache*)sharedInstance;
- (void)cachePhoto:(FlickrPhoto*)photo;

@end
