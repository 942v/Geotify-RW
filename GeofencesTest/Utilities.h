//
//  Utilities.h
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import MapKit;

@interface Utilities : NSObject

+ (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController;

+ (void)zoomToUserLocationInMapView:(MKMapView *)mapView;

@end
