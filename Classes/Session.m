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

@synthesize motionManager, currentOrientation, currentHeading, currentLocation, photoContainer;
@synthesize flickrAuthKey, flickrUsername, flickrFullname, flickrNsid;

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
		NSString *fak = [[NSUserDefaults standardUserDefaults] stringForKey:flickrAuthKeyKey];
		NSString *fun = [[NSUserDefaults standardUserDefaults] stringForKey:flickrUsernameKey];
		NSString *ffn = [[NSUserDefaults standardUserDefaults] stringForKey:flickrFullnameKey];
		NSString *fni = [[NSUserDefaults standardUserDefaults] stringForKey:flickrNsidKey];
		if(fak != nil)
			self.flickrAuthKey = fak;
		if(fun != nil)
			self.flickrUsername = fun;
		if(ffn != nil)
			self.flickrFullname = ffn;
		if(fni != nil)
			self.flickrNsid = fni;
		
		NSLog(@"recovered user defaults: flickrAuthKey: %@ flickrUsername: %@ flickrFullname: %@ flickrNsid: %@", 
			  self.flickrAuthKey, self.flickrUsername, self.flickrFullname, self.flickrNsid);
	}
	return self;
}

- (void)writeUserDefaults
{
	NSLog(@"writing user defaults");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.flickrAuthKey forKey:flickrAuthKeyKey];
	[defaults setObject:self.flickrUsername forKey:flickrUsernameKey];
	[defaults setObject:self.flickrFullname forKey:flickrFullnameKey];
	[defaults setObject:self.flickrNsid forKey:flickrNsidKey];
	[defaults synchronize];
}

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
