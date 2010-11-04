//
//  ElevationGrid.h
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/9/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SM3DAR.h"

#define GOOGLE_ELEVATION_API_URL_FORMAT @"http://maps.googleapis.com/maps/api/elevation/json?path=%@&samples=%i&sensor=false"

#define ELEVATION_PATH_SAMPLES 100
#define ELEVATION_LINE_LENGTH 25000

//#define ELEVATION_PATH_SAMPLES 150
//#define ELEVATION_LINE_LENGTH 660000

CLLocationDistance elevationData[ELEVATION_PATH_SAMPLES][ELEVATION_PATH_SAMPLES];
Coord3D worldCoordinateData[ELEVATION_PATH_SAMPLES][ELEVATION_PATH_SAMPLES];


@interface ElevationGrid : NSObject 
{
	CLLocation *gridOrigin;
}

@property (nonatomic, retain) CLLocation *gridOrigin;

- (id) initFromCache;
- (id) initFromFile:(NSString*)bundleFileName;
- (id) initAroundLocation:(CLLocation*)origin;
- (NSArray*) googlePathElevationBetween:(CLLocation*)point1 and:(CLLocation*)point2 samples:(NSInteger)samples;
- (CLLocation*) locationAtDistanceInMetersNorth:(CLLocationDistance)northMeters East:(CLLocationDistance)eastMeters fromLocation:(CLLocation*)origin;
- (void) buildArray;
- (NSString *) urlEncode:(NSString*)unencoded;
- (void) printElevationData:(BOOL)saveToCache;
- (CLLocation *) locationAtDistanceInMeters:(CLLocationDistance)meters bearingDegrees:(CLLocationDistance)bearing fromLocation:(CLLocation *)origin;
- (Coord3D *) worldCoordinates;
- (NSString *) dataFilePath;
- (void) loadDataFile:(NSString*)filePath;

@end
