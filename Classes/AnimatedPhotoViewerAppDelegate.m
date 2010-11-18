//
//  AnimatedPhotoViewerAppDelegate.m
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/2/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import "AnimatedPhotoViewerAppDelegate.h"
#import "AnimatedPhotoViewerViewController.h"
#import "CalculationUtil.h"
#import "Flickr.h"

@implementation AnimatedPhotoViewerAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{        
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
	[[Session sharedInstance] writeUserDefaults];
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
	[[Session sharedInstance] writeUserDefaults];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
	NSLog(@"opened app with url %@", url);

	if([url.scheme isEqualToString:@"geoflickr"])
	{  	//url is of the form: geoflickr://auth.success?frob=72157625288618289-38d6666c4b7f3cd4-5927508
		NSString *query = [url query];
		NSLog(@"query: %@", query);
		NSString *frob = [query substringFromIndex:5];
		NSLog(@"frob: %@", frob);
		[Session sharedInstance].flickrAuthKey = @"";
		[[Flickr sharedInstance] getAuthToken:frob];
		NSLog(@"authkey: %@", [Session sharedInstance].flickrAuthKey);
	}

	return YES;
}
#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!MEMORY WARNING!!!!!!!!!!!!!!!!!!!!!!");
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
