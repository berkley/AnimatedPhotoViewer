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

- (void)makeFlickrAPICallWithName:(NSString*)name params:(NSDictionary*)params queryType:(NSString*)qt
{
	queryType = qt;
	OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.context];
	[request setDelegate:self];
	[request callAPIMethodWithGET:name arguments:params];
}

//search flickr using the current values in Session
- (void)searchFlickr
{
	if([Session sharedInstance].currentLocation == nil)
	{ //don't run the query if we don't have a current location yet.
		return;
	}
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	NSMutableArray *objects = [[NSMutableArray alloc] init];

	//add the api key
	[keys addObject:@"api_key"];
	[objects addObject:self.apikey];
	
	//add the user id if we only want to search this users photos, don't add
	//anything to search public photos
	if([Session sharedInstance].searchMyPhotosOnly)
	{
		[keys addObject:@"user_id"];
		[objects addObject:@"me"];
	}
	
	//add the text based query if the query string isn't nil
	NSString *query = [Session trimString:[Session sharedInstance].query];
	if(![query isEqualToString:@""])
	{
		[keys addObject:@"text"];
		[objects addObject:query];
	}
	
	//add geo radius params
	[keys addObject:@"radius"];
	[objects addObject:[[NSNumber numberWithInt:[Session sharedInstance].distanceThreshold] stringValue]];
	
	//add current location
	[keys addObject:@"lat"];
	[objects addObject:[[NSNumber numberWithDouble:[Session sharedInstance].currentLocation.coordinate.latitude] stringValue]];
	[keys addObject:@"lon"];
	[objects addObject:[[NSNumber numberWithDouble:[Session sharedInstance].currentLocation.coordinate.longitude] stringValue]];
	
	//add units
	[keys addObject:@"radius_units"];
	[objects addObject:@"mi"];
	
	//add geo information and square icon url to the search results
	[keys addObject:@"extras"];
	[objects addObject:@"geo,url_sq,url_m"];
	
	//add the geo bounding box (triangle)
	/*[keys addObject:@"bbox"];
	double minLon, minLat, maxLon, maxLat;
	if([Session sharedInstance].currentLocation.coordinate.longitude > [Session sharedInstance].headingCornerAtDistance.coordinate.longitude)
	{
		maxLon = [Session sharedInstance].currentLocation.coordinate.longitude;
		minLon = [Session sharedInstance].headingCornerAtDistance.coordinate.longitude;
	}
	else 
	{
		minLon = [Session sharedInstance].currentLocation.coordinate.longitude;
		maxLon = [Session sharedInstance].headingCornerAtDistance.coordinate.longitude;
	}
	
	if([Session sharedInstance].currentLocation.coordinate.latitude > [Session sharedInstance].headingCornerAtDistance.coordinate.latitude)
	{
		maxLat = [Session sharedInstance].currentLocation.coordinate.latitude;
		minLat = [Session sharedInstance].headingCornerAtDistance.coordinate.latitude;
	}
	else 
	{
		minLat = [Session sharedInstance].currentLocation.coordinate.latitude;
		maxLat = [Session sharedInstance].headingCornerAtDistance.coordinate.latitude;
	}

	NSString *boundingCoords = [NSString stringWithFormat:@"%f,%f,%f,%f", minLon, minLat, maxLon, maxLat];
	[objects addObject:boundingCoords];*/
	 
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	NSLog(@"Query Params:");
	[Session inspectDictionary:dict];
											  
	[self makeFlickrAPICallWithName:@"flickr.photos.search" params:dict queryType:@"query"];
}

//sets Session.flickrAuthKey if successful
- (void)getAuthToken:(NSString*)frob
{
	NSArray *objects = [NSArray arrayWithObjects:self.apikey, frob, nil];
	NSArray *keys = [NSArray arrayWithObjects:@"api_key", @"frob", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[self makeFlickrAPICallWithName:@"flickr.auth.GetToken" params:dict queryType:@"getAuthToken"];
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
	else if([queryType isEqualToString:@"query"])
	{
		/*
		 <photos page="2" pages="89" perpage="10" total="881">
		 <photo id="2636" owner="47058503995@N01" 
			secret="a123456" server="2" title="test_04"
			ispublic="1" isfriend="0" isfamily="0" />
		 <photo id="2635" owner="47058503995@N01"
			secret="b123456" server="2" title="test_03"
			ispublic="0" isfriend="1" isfamily="1" />
		 <photo id="2633" owner="47058503995@N01"
			secret="c123456" server="2" title="test_01"
			ispublic="1" isfriend="0" isfamily="0" />
		 <photo id="2610" owner="12037949754@N01"
			secret="d123456" server="2" title="00_tall"
			ispublic="1" isfriend="0" isfamily="0" />
		 </photos>
		 //get back a dict that looks like this
		 //kick off a thread to cache returned photos
		 
		 */
		[Session inspectDictionary:inResponseDictionary];
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
	NSLog(@"flickr request of type %@ failed with error %@", queryType, [inError localizedDescription]);
	if([queryType isEqualToString:@"getAuthToken"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Authenticating" 
														message:[NSString stringWithFormat:@"Could not authenticate with Flickr: %@", [inError localizedDescription]]
													   delegate:self cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
	}
	else if([queryType isEqualToString:@"query"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Query Error" 
														message:[NSString stringWithFormat:@"There was an error querying Flickr: %@", [inError localizedDescription]] 
													   delegate:self 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
	NSLog(@"sending bytes to flickr");
}

@end
