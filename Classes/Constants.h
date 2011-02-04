//
//  Constants.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//


#define ANIMATIONDURATION      .5

//IPAD

//helps if this is a power of 2 since the ipad screen is a power of two on both dimensions
/*#define PHOTOWIDTH			   256
#define PHOTOHEIGHT			   256

#define OFFSCREENPOSOFFSET     512
#define OFFSCREENNEGOFFSET     -512
*/

//IPHONE 3GS

#define OFFSCREENPOSOFFSET     100
#define OFFSCREENNEGOFFSET     -100

#define PHOTOWIDTH			   80
#define PHOTOHEIGHT			   80

//accelerometer constants
#define kAccelerometerFrequency    1 //hz

#define PI 3.14159265

#define PHOTOWRITTEN @"FlickrPhotoWrittenToDisk"