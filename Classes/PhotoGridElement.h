//
//  PhotoGridElement.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/3/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoGridElement : NSObject {
	CGRect offScreenPosition;
	CGRect onScreenPosition;
	NSInteger column;
	NSInteger row;
	NSInteger numColumns;
	NSInteger numRows;
	NSString *photoName;

}

@property (nonatomic, assign) CGRect offScreenPosition;
@property (nonatomic, assign) CGRect onScreenPosition;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger numColumns;
@property (nonatomic, assign) NSInteger numRows;
@property (nonatomic, retain) NSString *photoName;

- (id)initWithRow:(NSInteger)r column:(NSInteger)col photoWidth:(NSInteger)pWidth photoHeight:(NSInteger)pHeight photoName:(NSString*)name;

@end
