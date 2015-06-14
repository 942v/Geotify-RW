//
//  Utilities.m
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)zoomToUserLocationInMapView:(MKMapView *)mapView{
    CLLocation *location = mapView.userLocation.location;
    if (location) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000.0f, 10000.0f);
        [mapView setRegion:region animated:YES];
    }
}

@end
