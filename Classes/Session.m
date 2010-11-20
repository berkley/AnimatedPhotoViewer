//
//  Session.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "Session.h"

@implementation Session

static Session *sharedInstance = nil;
static NSString *flickrAuthKeyKey = @"geoflickr.flickrAuthKey";
static NSString *flickrUsernameKey = @"geoflickr.flickrUsername";
static NSString *flickrFullnameKey = @"geoflickr.flickrFullname";
static NSString *flickrNsidKey = @"geoflickr.flickrNsid";
static NSString *searchMyPhotosOnlyKey = @"geoflickr.searchMyPhotosOnly";
static NSString *numberOfPhotosKey = @"geoflickr.numberOfPhotos";
static NSString *distanceThresholdKey = @"geoflickr.distanceThreshold";
static NSString *queryKey = @"geoflickr.queryKey";

@synthesize motionManager, currentOrientation, currentHeading, currentLocation, photoContainer;
@synthesize flickrAuthKey, flickrUsername, flickrFullname, flickrNsid;
@synthesize searchMyPhotosOnly, numberOfPhotos, distanceThreshold, query;

//init the class
- (id)init
{
	if(self = [super init])
	{
		motionManager = [[CMMotionManager alloc] init];
		photoContainer = [[PhotoGridElementContainer alloc]init];
		flickrAuthKey = nil;
		flickrUsername = nil;
		flickrFullname = nil;
		flickrNsid = nil;
		searchMyPhotosOnly = NO;
		numberOfPhotos = 80;
		distanceThreshold = 1;
		query = nil;
		
		//get the saved flickr values from UserDefaults
		NSString *fak = [[NSUserDefaults standardUserDefaults] stringForKey:flickrAuthKeyKey];
		NSString *fun = [[NSUserDefaults standardUserDefaults] stringForKey:flickrUsernameKey];
		NSString *ffn = [[NSUserDefaults standardUserDefaults] stringForKey:flickrFullnameKey];
		NSString *fni = [[NSUserDefaults standardUserDefaults] stringForKey:flickrNsidKey];
		NSString *q = [[NSUserDefaults standardUserDefaults] stringForKey:queryKey];
		NSInteger dt = [[NSUserDefaults standardUserDefaults] integerForKey:distanceThresholdKey];
		NSInteger np = [[NSUserDefaults standardUserDefaults] integerForKey:numberOfPhotosKey];
		BOOL smpo = [[NSUserDefaults standardUserDefaults] boolForKey:searchMyPhotosOnlyKey];

		self.distanceThreshold = dt;
		self.numberOfPhotos = np;
		
		if(smpo)
			self.searchMyPhotosOnly = YES;
		else 
			self.searchMyPhotosOnly = NO;

		if(fak != nil)
			self.flickrAuthKey = fak;
		if(fun != nil)
			self.flickrUsername = fun;
		if(ffn != nil)
			self.flickrFullname = ffn;
		if(fni != nil)
			self.flickrNsid = fni;
		if(q != nil)
			self.query = q;
		
		NSLog(@"recovered user defaults: flickrAuthKey: %@ flickrUsername: %@ flickrFullname: %@ flickrNsid: %@", 
			  self.flickrAuthKey, self.flickrUsername, self.flickrFullname, self.flickrNsid);
	}
	return self;
}

//save the flickr user information to UserDefaults
- (void)writeUserDefaults
{
	NSLog(@"writing user defaults");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.flickrAuthKey forKey:flickrAuthKeyKey];
	[defaults setObject:self.flickrUsername forKey:flickrUsernameKey];
	[defaults setObject:self.flickrFullname forKey:flickrFullnameKey];
	[defaults setObject:self.flickrNsid forKey:flickrNsidKey];
	[defaults setObject:self.query forKey:queryKey];
	[defaults setBool:self.searchMyPhotosOnly forKey:searchMyPhotosOnlyKey];
	[defaults setInteger:self.numberOfPhotos forKey:numberOfPhotosKey];
	[defaults setInteger:self.distanceThreshold forKey:distanceThresholdKey];
	[defaults synchronize];
}

//get the singleton instance of session
+ (Session*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[Session alloc] init];
		}		
    }
    return sharedInstance;
}
	
//print out the contents of a dictionary at level 0
+ (void)inspectDictionary:(NSDictionary*)dict
{
	for(int i=0l; i<[[dict allKeys] count]; i++)
	{
		NSString *key = [[dict allKeys] objectAtIndex:i];
		NSString *obj = [dict objectForKey:key];
		NSLog(@"key: %@, obj: %@", key, obj);
	}
}

@end
