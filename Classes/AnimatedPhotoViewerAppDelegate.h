//
//  AnimatedPhotoViewerAppDelegate.h
//  AnimatedPhotoViewer
//
//  Created by Chad Berkley on 11/2/10.
//  Copyright 2010 UCSB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnimatedPhotoViewerViewController;

@interface AnimatedPhotoViewerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AnimatedPhotoViewerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AnimatedPhotoViewerViewController *viewController;

@end

