//
//  UIApplication_TLCommon.h
//  TLCommon
//
//  Created by Joshua Bleecher Snyder on 9/11/09.
//

#import <Foundation/Foundation.h>


@interface UIApplication (TLCommon)

- (void)didStartNetworkRequest;
- (void)didStopNetworkRequest;

@end
