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

}

@property (nonatomic, assign) CGRect offScreenPosition;
@property (nonatomic, assign) CGRect onScreenPosition;

- (id)initWithRow:(NSInteger)r column:(NSInteger)col numRows:(NSInteger)numrows numCols:(NSInteger)numcols;

@end
