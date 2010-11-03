/*
 *  SM3DAR.h
 *  3DAR API header
 *
 *  Copyright 2010 Spot Metrix, Inc. All rights reserved.
 *  http://spotmetrix.com
 *
 *  Version 4.0.6
 *
 */

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

#define SM3DAR [SM3DAR_Controller sharedController]

@class SM3DAR_PointOfInterest;		
@class SM3DAR_Session;
@class SM3DAR_FocusView;

typedef struct
{
    CGFloat x, y, z;
} Coord3D;

@protocol SM3DAR_Delegate;


//
//
//
@protocol SM3DAR_PointProtocol
@property (nonatomic, assign) Coord3D worldPoint;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSObject<SM3DAR_Delegate> *selectionDelegate;
@property (assign) BOOL canReceiveFocus;
@property (assign) BOOL hasFocus;
- (Coord3D) worldCoordinate;
- (void) translateX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
- (Coord3D) unitVectorFromOrigin;
@optional
@property (nonatomic, assign) Coord3D worldPointVector;
- (void) step;
@end

typedef NSObject<SM3DAR_PointProtocol> SM3DAR_Point;


//
//
//
@protocol SM3DAR_Delegate
@optional
-(void)sm3darViewDidLoad;
-(void)loadPointsOfInterest;
-(void)didChangeFocusToPOI:(SM3DAR_Point*)newPOI fromPOI:(SM3DAR_Point*)oldPOI;
-(void)didChangeSelectionToPOI:(SM3DAR_Point*)newPOI fromPOI:(SM3DAR_Point*)oldPOI;
-(void)didChangeOrientationYaw:(CGFloat)yaw pitch:(CGFloat)pitch roll:(CGFloat)roll;
-(void)sm3darGLViewDidLoad;
-(void)sm3darWillInitializeOrigin;
-(void)logoWasTapped;
-(void)mapAnnotationView:(MKAnnotationView*)annotationView calloutAccessoryControlTapped:(UIControl*)control;
-(void)didShowMap;
-(void)didHideMap;
@end


//
//
//
@protocol SM3DAR_FocusDelegate
-(void)pointDidGainFocus:(SM3DAR_Point*)point;
@optional
-(void)pointDidLoseFocus:(SM3DAR_Point*)point;
-(void)updatePositionAndOrientation:(CGFloat)screenOrientationRadians;
@end


//
//
//
@interface SM3DAR_Controller : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate, MKMapViewDelegate> {
}

@property (assign) BOOL mapIsVisible;
@property (assign) BOOL originInitialized;
@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImagePickerController *camera;
@property (nonatomic, assign) NSObject<SM3DAR_Delegate> *delegate;
@property (nonatomic, retain) NSMutableDictionary *pointsOfInterest;
@property (nonatomic, retain) SM3DAR_Point *focusedPOI;
@property (nonatomic, retain) SM3DAR_Point *selectedPOI;
@property (nonatomic, assign) Class markerViewClass;
@property (nonatomic, retain) NSString *mapAnnotationImageName;
@property (nonatomic, retain) NSObject<SM3DAR_FocusDelegate> *focusView;
@property (nonatomic, assign) CGFloat screenOrientationRadians;
@property (nonatomic, retain) UIView *glView;
@property (nonatomic, assign) CGFloat nearClipMeters;
@property (nonatomic, assign) CGFloat farClipMeters;
@property (assign) NSTimeInterval locationUpdateInterval;
@property (nonatomic, assign) Coord3D worldPointTransform;
@property (nonatomic, assign) Coord3D worldPointVector;
@property (nonatomic, retain) UIButton *iconLogo;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLHeading *heading;
@property (nonatomic, assign) Coord3D currentPosition;
@property (nonatomic, assign) Coord3D downVector;
@property (nonatomic, assign) Coord3D northVector;
@property (nonatomic, assign) CGFloat currentYaw;
@property (nonatomic, assign) CGFloat currentPitch;
@property (nonatomic, assign) CGFloat currentRoll;
@property (nonatomic, assign) CGFloat mapZoomPadding;
@property (nonatomic, assign) CGFloat cameraAltitudeMeters;
@property (nonatomic, assign) BOOL running;

+ (SM3DAR_Controller*)sharedController;
+ (SM3DAR_Controller*)reinit;
+ (void)printMemoryUsage:(NSString*)message;
+ (void)printMatrix:(CATransform3D)t;
+ (Coord3D) worldCoordinateFor:(CLLocation*)location;
+ (Coord3D) unitVector:(Coord3D)coord;
- (void)forceRelease;
- (void)setFrame:(CGRect)newFrame;
- (void)addPoint:(SM3DAR_Point*)point;
- (void)addPointOfInterest:(SM3DAR_Point*)point;
- (void)addPointsOfInterest:(NSArray*)points;
- (void)removePointOfInterest:(SM3DAR_Point*)point;
- (void)removePointsOfInterest:(NSArray*)points;
- (void)removeAllPointsOfInterest;
- (void)replaceAllPointsOfInterestWith:(NSArray*)points;
- (NSString*)loadJSONFromFile:(NSString*)fileName;
- (void)loadMarkersFromJSONFile:(NSString*)fileName;
- (void)loadMarkersFromJSON:(NSString*)json;
- (NSString*)loadCSVFromFile:(NSString*)fileName;
- (void)loadMarkersFromCSVFile:(NSString*)fileName hasHeader:(BOOL)hasHeader;
- (void)loadMarkersFromCSV:(NSString*)csv hasHeader:(BOOL)hasHeader;
- (SM3DAR_PointOfInterest*)initPointOfInterest:(NSDictionary*)properties;
- (SM3DAR_PointOfInterest*)initPointOfInterestWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CGFloat)altitude title:(NSString*)poiTitle subtitle:(NSString*)poiSubtitle markerViewClass:(Class)poiMarkerViewClass properties:(NSDictionary*)properties;
- (SM3DAR_PointOfInterest*)initPointOfInterest:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CGFloat)altitude title:(NSString*)poiTitle subtitle:(NSString*)poiSubtitle markerViewClass:(Class)poiMarkerViewClass properties:(NSDictionary*)properties;
- (void)addPointOfInterestWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CGFloat)altitude title:(NSString*)poiTitle subtitle:(NSString*)poiSubtitle markerViewClass:(Class)poiMarkerViewClass properties:(NSDictionary*)properties;
- (BOOL)changeCurrentLocation:(CLLocation*)newLocation;
- (BOOL)displayPoint:(SM3DAR_Point*)poi;
- (void)startCamera;
- (void)stopCamera;
- (void)suspend;
- (void)resume;
- (CATransform3D)cameraTransform;
- (Coord3D)cameraPosition;
- (void)debug:(NSString*)message;
- (CGRect)logoFrame;
- (BOOL)isTiltLookMode;
- (void)toggleLookMode;
- (NSString*)exportPointsOfInterestAsJSON;
- (NSString*)exportPointsOfInterestAsCSV;
- (void)initMap;
- (void)toggleMap;
- (void)showMap;
- (void)hideMap;
- (void)zoomMapToFit;
- (void)zoomMapToFitPointsIncludingUserLocation:(BOOL)includeUser;
- (void)setCurrentMapLocation:(CLLocation *)location;
- (void)fadeMapToAlpha:(CGFloat)alpha;
- (BOOL)setMapVisibility;
- (void)annotateMap;
- (void)centerMapOnCurrentLocation;
- (Coord3D)solarPosition;
- (Coord3D)solarPositionScaled:(CGFloat)meters;
- (void)initOrigin;
- (Coord3D)ray:(CGPoint)screenPoint;
@end


//
//
//
@interface SM3DAR_Fixture : NSObject <SM3DAR_PointProtocol> {
}
@property (nonatomic, assign) CGFloat gearPosition;
- (CGFloat)gearSpeed;
- (NSInteger)numberOfTeethInGear;
- (void) gearHasTurned;
- (Coord3D) unitVectorFromOrigin;
@end


//
//
//
@interface SM3DAR_PointOfInterest : CLLocation <MKAnnotation, SM3DAR_PointProtocol> {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, retain) NSURL *dataURL;
@property (nonatomic, assign) NSObject<SM3DAR_Delegate> *delegate;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) Class annotationViewClass;
@property (nonatomic, retain) NSString *mapAnnotationImageName;
@property (assign) BOOL hasFocus;
@property (assign) BOOL canReceiveFocus;
@property (nonatomic, assign) CGFloat gearPosition;

- (id)initWithLocation:(CLLocation*)loc properties:(NSDictionary*)props;
- (id)initWithLocation:(CLLocation*)loc title:(NSString*)title subtitle:(NSString*)subtitle url:(NSURL*)url;
- (CGFloat)distanceInMetersFrom:(CLLocation*)otherPoint;
- (CGFloat)distanceInMetersFromCurrentLocation;
- (NSString*)formattedDistanceInMetersFrom:(CLLocation*)otherPoint;
- (NSString*)formattedDistanceInMetersFromCurrentLocation;
- (CGFloat)distanceInMilesFrom:(CLLocation*)otherPoint;
- (CGFloat)distanceInMilesFromCurrentLocation;
- (NSString*)formattedDistanceInMilesFrom:(CLLocation*)otherPoint;
- (NSString*)formattedDistanceInMilesFromCurrentLocation;
- (BOOL)isInView:(CGPoint*)point;
- (CATransform3D)objectTransform;
- (CGFloat)gearSpeed;
- (NSInteger)numberOfTeethInGear;
- (void) gearHasTurned;
- (Coord3D) unitVectorFromOrigin;

@end


//
//
//
@interface SM3DAR_PointView : UIView {
}

@property (nonatomic, retain) SM3DAR_Point *point;

- (void) buildView;
- (CGAffineTransform) pointTransform;
- (void) didReceiveFocus;
- (void) didLoseFocus;
- (void) resizeFrameAround:(UIView*)targetView;
@end


//
//
//
@interface SM3DAR_MarkerView : SM3DAR_PointView {
}

@property (nonatomic, retain) SM3DAR_PointOfInterest *poi;

- (id)initWithPointOfInterest:(SM3DAR_PointOfInterest*)pointOfInterest;
@end


//
//
//
@interface SM3DAR_IconMarkerView : SM3DAR_MarkerView {
}

@property (nonatomic, retain) UIImageView *icon;

+ (NSString*)randomIconName;
@end


//
//
//
@interface SM3DAR_GLMarkerView : SM3DAR_MarkerView {
}

- (void) drawInGLContext;
@end


//
//
//
@interface SM3DAR_FocusView : UIView<SM3DAR_FocusDelegate> {
}

@property (nonatomic, retain) SM3DAR_Point *focusPoint;
@property (nonatomic, retain) UILabel *content;
@property (nonatomic, assign) BOOL showDistance;
@property (nonatomic, assign) BOOL showTitle;
@property (nonatomic, assign) BOOL useMetricUnits;
@property (nonatomic, assign) CGPoint centerOffset;

- (void)buildView;
@end


//
//
//
@interface Texture : NSObject {
}

@property (nonatomic) unsigned int handle;

+ (Texture*) newTexture;
+ (Texture*) newTextureFromImage:(CGImageRef)image;
+ (Texture*) newTextureFromResource:(NSString*)resource;
- (void) replaceTextureFromResource:(NSString*)resource;
- (void) replaceTextureWithImage:(CGImageRef)image;
@end


//
//
//
@interface Geometry : NSObject {
}

@property (nonatomic) BOOL cullFace;

+ (Geometry *) newOBJFromResource:(NSString *)resource;
+ (void) displayHemisphereWithTexture:(Texture *)texture;
+ (void) displaySphereWithTexture:(Texture *)texture;
- (void) displayWireframe;
- (void) displayFilledWithTexture:(Texture *)texture;
- (void) displayShaded:(UIColor *)color;
@end


//
//
//
@interface SM3DAR_CustomAnnotationView : MKAnnotationView { 
}
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) SM3DAR_PointOfInterest *poi;
@end


#define SM3DAR_POI_LATITUDE @"latitude"
#define SM3DAR_POI_ALTITUDE @"altitude"
#define SM3DAR_POI_LONGITUDE @"longitude"
#define SM3DAR_POI_TITLE @"title"
#define SM3DAR_POI_SUBTITLE @"subtitle"
#define SM3DAR_POI_URL @"url"
#define SM3DAR_POI_VIEW_CLASS_NAME @"view_class_name"
#define SM3DAR_POI_DEFAULT_VIEW_CLASS_NAME @"SM3DAR_IconMarkerView"

