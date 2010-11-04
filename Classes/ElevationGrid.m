//
//  ElevationGrid.m
//  BezierGarden
//
//  Created by P. Mark Anderson on 10/9/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import "ElevationGrid.h"
#import "NSDictionary+BSJSONAdditions.h"

#define DEG2RAD(A)			((A) * 0.01745329278)
#define RAD2DEG(A)			((A) * 57.2957786667)

// WGS-84 ellipsoid
#define RADIUS_EQUATORIAL_A 6378137
#define RADIUS_POLAR_B 6356752.3142
#define INVERSE_FLATTENING 	1/298.257223563



@implementation ElevationGrid

@synthesize gridOrigin;

- (void) dealloc
{
	self.gridOrigin = nil;
    [super dealloc];
}

- (id) initFromFile:(NSString*)bundleFileName
{
    if (self = [super init])
    {
        self.gridOrigin = nil;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:bundleFileName ofType:nil];
        [self loadDataFile:filePath];        
    }
    
    return self;
}
        
- (id) initFromCache
{
    if (self = [super init])
    {
        self.gridOrigin = nil;

        [self loadDataFile:[self dataFilePath]];        
    }
    
    return self;
}

- (id) initAroundLocation:(CLLocation*)origin
{
    if (self = [super init])
    {
        self.gridOrigin = origin;
        
        [self buildArray];
    }
    
    return self;
}

#pragma mark -
- (Coord3D*) worldCoordinates
{
    return *worldCoordinateData;
}

#pragma mark -

- (NSArray*) getChildren:(id)data parent:(NSString*)parent
{	    
    if ( ! data || [data count] == 0) 
        return nil;
    
    if ([parent length] > 0)
    {
        data = [data objectForKey:parent]; 

        if ( ! data || [data count] == 0) 
            return nil;
    }
    
    if ([data isKindOfClass:[NSArray class]]) 
        return data;
    
    if ([data isKindOfClass:[NSDictionary class]]) 
        return [NSArray arrayWithObject:data];
    
    return nil;
}

- (NSString *) dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return [documentsDirectoryPath stringByAppendingPathComponent:@"elevation_grid.txt"];
}

- (NSArray*) googlePathElevationBetween:(CLLocation*)point1 and:(CLLocation*)point2 samples:(NSInteger)samples
{
    NSLog(@"[EG] Fetching elevation data...");
    
    // Build the request.
    NSString *pathString = [NSString stringWithFormat:
                            @"%f,%f|%f,%f",
                            point1.coordinate.latitude, 
                            point1.coordinate.longitude,
                            point2.coordinate.latitude, 
                            point2.coordinate.longitude];
    
    NSString *requestURI = [NSString stringWithFormat:
                            GOOGLE_ELEVATION_API_URL_FORMAT,
                            [self urlEncode:pathString],
                            samples];
    
	// Fetch the elevations from google as JSON.
    NSError *error;
    NSLog(@"[EG] URL:\n\n%@\n\n", requestURI);

	NSString *responseJSON = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestURI] 
                                                  encoding:NSUTF8StringEncoding error:&error];    

    
    if ([responseJSON length] == 0)
    {
        NSLog(@"[EG] Empty response. %@, %@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    
    /* Example response:
    {
        "status": "OK",
        "results": [ {}, {} ]
    }
     Status code may be one of the following:
     - OK indicating the API request was successful
     - INVALID_REQUEST indicating the API request was malformed
     - OVER_QUERY_LIMIT indicating the requestor has exceeded quota
     - REQUEST_DENIED indicating the API did not complete the request, likely because the requestor failed to include a valid sensor parameter
     - UNKNOWN_ERROR indicating an unknown error
    */
    
    // Parse the JSON response.
    id data = [NSDictionary dictionaryWithJSONString:responseJSON];

    // Get the request status.
    NSString *status = [data objectForKey:@"status"];    
    NSLog(@"[EG] Request status: %@", status);    

    if ([status isEqualToString:@"OVER_QUERY_LIMIT"])
    {
        NSLog(@"[EG] Over query limit!");
        return nil;
    }

    // Get the result data items. See example below.
    /* 
     {
         "location": 
         {
             "lat": 36.5718491,
             "lng": -118.2620657
         },
         "elevation": 3303.3430176
     }
    */
    
	NSArray *results = [self getChildren:data parent:@"results"];        
    //NSLog(@"RESULTS:\n\n%@", results);
    
    NSMutableArray *pathLocations = [NSMutableArray arrayWithCapacity:[results count]];
    NSString *elevation, *lat, *lng;
    CLLocation *tmpLocation;
    CLLocationDistance alt;
    CLLocationCoordinate2D coordinate;
    
    for (NSDictionary *oneResult in results)
    {
        NSDictionary *locationData = [oneResult objectForKey:@"location"];
        
        // TODO: Make sure the location data is valid.
        lat = [locationData objectForKey:@"lat"];
        coordinate.latitude = [lat doubleValue];
        
        lng = [locationData objectForKey:@"lng"];
        coordinate.longitude = [lng doubleValue];

        elevation = [oneResult objectForKey:@"elevation"];        
		alt = [elevation doubleValue];
                
        tmpLocation = [[CLLocation alloc] initWithCoordinate:coordinate 
                                                    altitude:alt
                                          horizontalAccuracy:-1 
                                            verticalAccuracy:-1 
                                                   timestamp:nil];
        
        [pathLocations addObject:tmpLocation];
        [tmpLocation release];
    }
    
    return pathLocations;
}

- (CLLocation*) locationAtDistanceInMetersNorth:(CLLocationDistance)northMeters
                                           East:(CLLocationDistance)eastMeters
                                   fromLocation:(CLLocation*)origin
{
    CLLocationDegrees latitude, longitude;
    
    // Latitude
    if (northMeters == 0) 
    {
        latitude = origin.coordinate.latitude;
    }
    else
    {
        CGFloat deltaLat = 
     	latitude = origin.coordinate.latitude + deltaLat;
    }
    
    
    // Longitude
    if (eastMeters == 0) 
    {
        longitude = origin.coordinate.longitude;
    }
    else
    {
        CGFloat deltaLng = eastMeters / 10000.0;
//        CGFloat deltaLng = atanf((ELEVATION_LINE_LENGTH/2) / [self longitudinalRadius:origin.coordinate.latitude]);
     	longitude = origin.coordinate.longitude + deltaLng;
    }
    
	return [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
}

- (CLLocation*) pathEndpointFrom:(CLLocation*)startPoint
{
    CLLocationCoordinate2D endPoint;
    CGFloat delta = (ELEVATION_LINE_LENGTH / 10000.0);
    endPoint.latitude = startPoint.coordinate.latitude - delta;
    endPoint.longitude = startPoint.coordinate.longitude;

    return [[[CLLocation alloc] initWithCoordinate:endPoint altitude:0 horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:nil] autorelease];
    
    
//    return [self locationAtDistanceInMetersNorth:-ELEVATION_LINE_LENGTH
//                                            East:0
//                                    fromLocation:startPoint];
}

- (CLLocation *) locationEastOf:(CLLocation *)northPoint byDegrees:(CLLocationDegrees)lonSegLenDegrees
{
    return [[[CLLocation alloc] initWithLatitude:northPoint.coordinate.latitude 
                                                       longitude:northPoint.coordinate.longitude + lonSegLenDegrees] autorelease];
    
}

- (void) buildArray
{    
    CGFloat halfLineLength = ELEVATION_LINE_LENGTH / 2;    
    CGFloat cornerPointDistanceMeters = sqrtf( 2 * (halfLineLength * halfLineLength) );
    CGFloat bearingDegrees = -45.0;

    // Get the north-west point location.
    CLLocation *pointNW = [self locationAtDistanceInMeters:cornerPointDistanceMeters 
                                           bearingDegrees:bearingDegrees
                                             fromLocation:gridOrigin];
    
    // Get the south-east point location.
    CLLocation *pointSE = [self locationAtDistanceInMeters:cornerPointDistanceMeters 
                                             bearingDegrees:bearingDegrees+180.0
                                               fromLocation:gridOrigin];
    
    
    // Get the lon seg len deg
    CLLocationDegrees pointNWLongitude = pointNW.coordinate.longitude;
    CLLocationDegrees pointSELongitude = pointSE.coordinate.longitude;
    CLLocationDegrees lineLengthDegrees = fabsf(
                        (180 + pointNWLongitude) -
                        (180 + pointSELongitude));
    
    CLLocationDegrees lonSegLenDegrees = lineLengthDegrees / ELEVATION_PATH_SAMPLES;

    // Make the SW point.
    CLLocationDegrees pointSWLatitude = pointSE.coordinate.latitude;
    CLLocation *pointSW = [[[CLLocation alloc] initWithLatitude:pointSWLatitude longitude:pointNWLongitude] autorelease];
    
    CLLocation *northPoint = pointNW;
    CLLocation *southPoint = pointSW;
    
    for (int i=0; i < ELEVATION_PATH_SAMPLES; i++)
    {        
        NSLog(@"Getting elevations between %@ and %@", northPoint, southPoint);
        
        NSArray *pathLocations = [self googlePathElevationBetween:northPoint 
                                                              and:southPoint 
                                                          samples:ELEVATION_PATH_SAMPLES];    
        
        // Validate path elevation data returned from google's elevation API.
        if (!pathLocations || [pathLocations count] == 0)
        {
            //NSLog(@"[EG] WARNING: Google failed.");
			continue;            
        }
        
        // Move meridian points east.
        NSLog(@"Moving east: %.3f deg", lonSegLenDegrees);
        
		northPoint = [self locationEastOf:northPoint byDegrees:lonSegLenDegrees];        
		southPoint = [self locationEastOf:southPoint byDegrees:lonSegLenDegrees];        
        
        // Parse results.
        for (int j=0; j < ELEVATION_PATH_SAMPLES; j++)
        {
            CLLocation *tmpLocation = [pathLocations objectAtIndex:j];

            elevationData[j][i] = tmpLocation.altitude;
            
            worldCoordinateData[j][i] = [SM3DAR_Controller worldCoordinateFor:tmpLocation];
        }
    }

	[self printElevationData:YES];
}

- (void) printElevationData:(BOOL)saveToCache
{
    CGFloat len = ELEVATION_LINE_LENGTH / 1000.0;
    NSMutableString *str = [NSMutableString stringWithFormat:@"\n\n%i elevation samples in a %.1f sq km grid\n", ELEVATION_PATH_SAMPLES, len, len];
    NSMutableString *wpStr = [NSMutableString string];
    
    for (int i=0; i < ELEVATION_PATH_SAMPLES; i++)
    {
        [str appendString:@"\n"];
        [wpStr appendString:@"\n"];

        for (int j=0; j < ELEVATION_PATH_SAMPLES; j++)
        {
            Coord3D c = worldCoordinateData[i][j];
            [wpStr appendFormat:@"%.0f,%.0f,%.0f ", c.x, c.y, c.z];            
            
            CGFloat elevation = elevationData[i][j];            

            if (abs(elevation) < 10) [str appendString:@" "];
            if (abs(elevation) < 100) [str appendString:@" "];
            if (abs(elevation) < 1000) [str appendString:@" "];
            
            if (elevation < 0)
            {
                [str replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }

            [str appendFormat:@"%.0f ", elevation];                        
        }

    }

    [str appendString:@"\n\n"];
    [wpStr appendString:@"\n\n"];

    //NSLog(str, 0);

    //NSLog(@"\n\nWorld coordinates:\n");
    //NSLog(wpStr, 0);

    if (saveToCache)
    {
        NSString *filePath = [self dataFilePath];
        NSLog(@"[EG] Saving world coordinates to %@", filePath);
        [wpStr writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    
}

#pragma mark -
- (NSString *) urlEncode:(NSString*)unencoded
{
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                               NULL,
                                                               (CFStringRef)unencoded,
                                                               NULL,
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]|",
                                                               kCFStringEncodingUTF8);
}

#pragma mark Vincenty

/**
 * destinationVincenty
 * Calculate destination point given start point lat/long (numeric degrees),
 * bearing (numeric degrees) & distance (in m).
 * Adapted from Chris Veness work, see
 * http://www.movable-type.co.uk/scripts/latlong-vincenty-direct.html
 *
 */
- (CLLocation *) locationAtDistanceInMeters:(CLLocationDistance)meters bearingDegrees:(CLLocationDistance)bearing fromLocation:(CLLocation *)origin
{
    CGFloat a = RADIUS_EQUATORIAL_A;
    CGFloat b = RADIUS_POLAR_B;
	CGFloat f = INVERSE_FLATTENING;
    
    CLLocationDegrees lon1 = origin.coordinate.longitude;
    CLLocationDegrees lat1 = origin.coordinate.latitude;

	CGFloat s = meters;
	CGFloat alpha1 = DEG2RAD(bearing);

    CGFloat sinAlpha1 = sinf(alpha1);
    CGFloat cosAlpha1 = cosf(alpha1);
    
    CGFloat tanU1 = (1-f) * tanf(DEG2RAD(lat1));
    CGFloat cosU1 = 1 / sqrtf((1 + tanU1*tanU1)), 
	sinU1 = tanU1*cosU1;

    CGFloat sigma1 = atan2(tanU1, cosAlpha1);
    CGFloat sinAlpha = cosU1 * sinAlpha1;
    CGFloat cosSqAlpha = 1 - sinAlpha*sinAlpha;
    CGFloat uSq = cosSqAlpha * (a*a - b*b) / (b*b);
    CGFloat A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
    CGFloat B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
    
    CGFloat sigma = s / (b*A);
	CGFloat sigmaP = 2*M_PI;
    
	CGFloat cos2SigmaM, sinSigma, cosSigma, deltaSigma;
    
    while (fabs(sigma-sigmaP) > 1e-12) 
	{
        cos2SigmaM = cosf(2*sigma1 + sigma);
        sinSigma = sinf(sigma);
        cosSigma = cosf(sigma);
        deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-
                                                         B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
        sigmaP = sigma;
        sigma = s / (b*A) + deltaSigma;
    }
    
    CGFloat tmp = sinU1*sinSigma - cosU1*cosSigma*cosAlpha1;
    CGFloat lat2 = atan2(sinU1*cosSigma + cosU1*sinSigma*cosAlpha1,
                          (1-f)*sqrt(sinAlpha*sinAlpha + tmp*tmp));
    CGFloat lambda = atan2(sinSigma*sinAlpha1, cosU1*cosSigma - sinU1*sinSigma*cosAlpha1);
    CGFloat C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
    CGFloat L = lambda - (1-C) * f * sinAlpha *
    (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
    
//    CGFloat revAz = atan2(sinAlpha, -tmp);  // final bearing
    
	CLLocationDegrees destLatitude = RAD2DEG(lat2);
	CLLocationDegrees destLongitude = lon1+RAD2DEG(L);
	CLLocation *location = [[CLLocation alloc] initWithLatitude:destLatitude longitude:destLongitude];

    return [location autorelease];
}

#pragma mark -

- (void) loadDataFile:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSLog(@"[EG] loadDataFile: %@", filePath);
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        // Load cached data.
        NSLog(@"[EG] Loading elevation grid from file.");
        
        NSError *error = nil;
        NSString *coordData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        
        if (error)
        {
            NSLog(@"[EG] ERROR: ", [error localizedDescription]);
            [self release];
        }
        else
        {
            //NSLog(@"\n\n%@\n\n", coordData);
            
            // Parse data.  Extract lines first.
            NSArray *lines = [coordData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            if (!lines || [lines count] == 0)
            {
                NSLog(@"[EG] Cache file is empty.");
                [self release];
            }
            else
            {
                NSInteger i = 0;
                
                // Parse each line.                    
                for (NSString *oneLine in lines)
                {
                    if ([oneLine length] == 0)
                    {
                        // Skip blank line.
                        continue;
                    }
                    
                    // Each coordinate triplet is separated by a space.
                    NSArray *coords = [oneLine componentsSeparatedByString:@" "];
                    
                    NSInteger j = 0;
                    
                    for (NSString *csv in coords)
                    {
                        if ([csv length] == 0)
                        {
                            // Skip empty triplet.
                            continue;
                        }
                        
                        // Each coordinate is represented as X,Y,Z.
                        NSArray *xyz = [csv componentsSeparatedByString:@","];
                        
                        if (!xyz || [xyz count] < 3)
                        {
                            NSLog(@"[EG] Invalid triplet format: %@", csv);
                            
                            continue;
                        }
                        
                        Coord3D coord;
                        
                        @try 
                        {
                            coord.x = [[xyz objectAtIndex:0] floatValue];
                            coord.y = [[xyz objectAtIndex:1] floatValue];
                            coord.z = [[xyz objectAtIndex:2] floatValue];
                        }
                        @catch (NSException *e) 
                        {
                            NSLog(@"[EG] Unable to convert triplet to coordinate: %@", [e reason]);
                            j++;
                            continue;                                
                        }
                        
                        //NSLog(@"[%i][%i] Z: %.0f", i, j, coord.z);
                        
                        worldCoordinateData[i][j] = coord;
                        
                        j++;
                        // End of triplet.
                    }
                    
                    if (j >= ELEVATION_PATH_SAMPLES)
                    {
                        // Only increment i if we parsed the right number triplets.
                        i++;
                    }
                    
                    // End of line.
                }
            }
        }
        
        [self printElevationData:NO];
    }
    else
    {
        NSLog(@"[EG] No cache file.");
        [self release];
    }
    
}

@end
