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
//static CMMotionManager *motionManager;

+ (Session*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[Session alloc] init];
			//motionManager = [[CMMotionManager alloc] init];
		}		
    }
    return sharedInstance;
}
	

@end
