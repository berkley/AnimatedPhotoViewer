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

@synthesize motionManager;

- (id)init
{
	if(self = [super init])
	{
		motionManager = [[CMMotionManager alloc] init];
	}
	return self;
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
	

@end
