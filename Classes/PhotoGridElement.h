//
//  PhotoGridElement.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoGridElement : UIImageView {
	CGRect offScreenPosition;
	CGRect onScreenPosition;
	NSInteger column;
	NSInteger row;
	NSInteger numColumns;
	NSInteger numRows;
	NSString *photoName;
	CGFloat latitude;
	CGFloat longitude;
}

@property (nonatomic, assign) CGRect offScreenPosition;
@property (nonatomic, assign) CGRect onScreenPosition;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger numColumns;
@property (nonatomic, assign) NSInteger numRows;
@property (nonatomic, retain) NSString *photoName;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

- (id)initWithRow:(NSInteger)r column:(NSInteger)col photoWidth:(NSInteger)pWidth 
	  photoHeight:(NSInteger)pHeight photoName:(NSString*)name lat:(CGFloat)lat lon:(CGFloat)lon;
- (void)swapFrames;

@end
