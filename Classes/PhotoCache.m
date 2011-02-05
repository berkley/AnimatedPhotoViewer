//
//  PhotoCache.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/30/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "PhotoCache.h"
#import "FlickrPhotoDownloader.h"
#import "Session.h"

@implementation PhotoCache

NSString *cachePath;
NSMutableDictionary *cachedFilesDict;
NSOperationQueue *operationQueue;
static PhotoCache *sharedInstance = nil;

//check to make sure we're under our limit.  If not,
//get rid of the cruft
- (void)purgeCache
{
	
}

- (id)init
{
	if(self = [super init])
	{
		NSLog(@"!!!!!!!!!!!!!!!!setting up the cache");
		BOOL success;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		cachePath = [documentsDirectory stringByAppendingPathComponent:@"photoCache"];
		[cachePath retain];
		success = [fileManager fileExistsAtPath:cachePath];
		operationQueue = [[NSOperationQueue alloc] init];
		cachedFilesDict = [[NSMutableDictionary alloc] init];
		[Session sharedInstance].cachePath = cachePath;
		if(success) 
		{
			return self;        
		}
		
		success = [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
		if(!success)
		{
			NSLog(@"Cache directory is %@", cachePath);
			NSAssert1(0, @"Failed to create cache directory with message '%s'.", [error localizedDescription]);
		}
		
		NSLog(@"cache path is: %@", cachePath);
	}
	return self;
}

+ (PhotoCache*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[PhotoCache alloc] init];
		}		
    }
    return sharedInstance;
}

//cache a single photo
- (void)cachePhoto:(FlickrPhoto*)photo
{
	NSLog(@"caching photo with id %i", photo.photoId);
	//download the photo to cachePath
	NSString *idStr = [NSString stringWithFormat:@"%i", photo.photoId];
	NSLog(@"cache location: %@", cachePath);
	NSString *cacheLocation = [cachePath stringByAppendingPathComponent:idStr];

	//register it in cachedFilesDict
	[cachedFilesDict setObject:photo forKey:idStr];

	NSLog(@"cached photo %@ to location %@", idStr, cacheLocation);

	FlickrPhotoDownloader *downloader = [[FlickrPhotoDownloader alloc] initWithPhoto:photo writeLocation:cacheLocation];
	NSLog(@"adding downloader operation for photo %@", idStr);
	[operationQueue addOperation:downloader];
	NSInteger count = [operationQueue operationCount];
	NSLog(@"currently %i ops in the queue", count);
	
	//kick off purgeCache in a new thread to check for overage
}

- (NSDictionary*)getFlickrPhotosInCache
{
	return cachedFilesDict;
}

@end
