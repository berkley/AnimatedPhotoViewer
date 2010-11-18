//
//  Flickr.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/16/10.
//  Copyright 2010 OffHeGoes. All rights reserved.
//

#import "Flickr.h"
#import "Session.h"

@implementation Flickr

@synthesize apikey, secret, context;

static Flickr *sharedInstance = nil;
NSString *queryType;

//url protocol: geoflickr://auth.success

+ (Flickr*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[Flickr alloc] init];
		}		
    }
    return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		secret = @"2095762ff1a7b481";
		apikey = @"06878e5364a281e7ccdc5b5f8f85e57e";
		context = [[OFFlickrAPIContext alloc] initWithAPIKey:apikey sharedSecret:secret];
	}
	return self;
}

- (void)openAuthUrl
{
	NSURL *url = [self.context loginURLFromFrobDictionary:nil requestedPermission:@"read"];
	
	if (![[UIApplication sharedApplication] openURL:url])
	{
		NSLog(@"%@%@",@"Failed to open url:",[url description]);		
	}
}

//sets Session.flickrAuthKey if successful
- (void)getAuthToken:(NSString*)frob
{
	OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.context];
	[request setDelegate:self];
	NSArray *objects = [NSArray arrayWithObjects:self.apikey, frob, nil];
	NSArray *keys = [NSArray arrayWithObjects:@"api_key", @"frob", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[request callAPIMethodWithGET:@"flickr.auth.GetToken" arguments:dict];
	queryType = @"getAuthToken";
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
	if([queryType isEqualToString:@"getAuthToken"])
	{
		NSDictionary *auth = [inResponseDictionary objectForKey:@"auth"];
		
		NSDictionary *token = [auth objectForKey:@"token"];
		[Session sharedInstance].flickrAuthKey = [token objectForKey:@"_text"];
		
		NSDictionary *user = [auth objectForKey:@"user"];
		[Session sharedInstance].flickrUsername = [user objectForKey:@"username"];
		[Session sharedInstance].flickrFullname = [user objectForKey:@"fullname"];
		[Session sharedInstance].flickrNsid = [user objectForKey:@"nsid"];
			
		NSLog(@"set flickrAuthKey to %@", [Session sharedInstance].flickrAuthKey);
		NSLog(@"set flickrUsername to %@", [Session sharedInstance].flickrUsername);
		NSLog(@"set flickrFullname to %@", [Session sharedInstance].flickrFullname);
		NSLog(@"set flickrNsid to %@", [Session sharedInstance].flickrNsid);
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
	if([queryType isEqualToString:@"getAuthToken"])
	{
		NSLog(@"flickr request of type %@ failed with error %@", queryType, [inError localizedDescription]);
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
	
}

@end
