//
//  GeotificationsViewController.m
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import "GeotificationsViewController.h"
#import "AddGeotificationViewController.h"

#import "Geotification.h"
#import "Utilities.h"

@import MapKit;

@interface GeotificationsViewController () <MKMapViewDelegate, AddGeotificationsViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *geotifications;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation GeotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];
    
    [self loadAllGeotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Loading and saving functions

- (void)loadAllGeotifications{
    self.geotifications = [NSMutableArray array];
    
    NSArray *savedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedItemsKey];
    if (savedItems) {
        for (id savedItem in savedItems) {
            Geotification *geotification = [NSKeyedUnarchiver unarchiveObjectWithData:savedItem];
            if ([geotification isKindOfClass:[Geotification class]]) {
                [self addGeotification:geotification];
            }
        }
    }
}

- (void)saveAllGeotifications{
    NSMutableArray *items = [NSMutableArray array];
    for (Geotification *geotification in self.geotifications) {
        id item = [NSKeyedArchiver archivedDataWithRootObject:geotification];
        [items addObject:item];
    }
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:kSavedItemsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Functions that update the model/associated views with geotification changes

- (void)addGeotification:(Geotification *)geotification{
    [self.geotifications addObject:geotification];
    [self.mapView addAnnotation:geotification];
    [self addRadiusOverlayForGeotification:geotification];
    [self updateGeotificationsCount];
}

- (void)removeGeotification:(Geotification *)geotification{
    [self.geotifications removeObject:geotification];
    
    [self.mapView removeAnnotation:geotification];
    [self removeRadiusOverlayForGeotification:geotification];
    [self updateGeotificationsCount];
}

- (void)updateGeotificationsCount{
    self.title = [NSString stringWithFormat:@"Geotifications (%lu)", (unsigned long)self.geotifications.count];
    [self.navigationItem.rightBarButtonItem setEnabled:self.geotifications.count<20];
}

#pragma mark - AddGeotificationViewControllerDelegate

- (void)addGeotificationViewController:(AddGeotificationViewController *)controller didAddCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius identifier:(NSString *)identifier note:(NSString *)note eventType:(EventType)eventType{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    CGFloat clampedRadius = (radius > self.locationManager.maximumRegionMonitoringDistance)?self.locationManager.maximumRegionMonitoringDistance : radius;
    Geotification *geotification = [[Geotification alloc] initWithCoordinate:coordinate radius:clampedRadius identifier:identifier note:note eventType:eventType];
    [self addGeotification:geotification];
    [self startMonitoringGeotification:geotification];
    
    [self saveAllGeotifications];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *identifier = @"myGeotification";
    if ([annotation isKindOfClass:[Geotification class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (![annotation isKindOfClass:[MKPinAnnotationView class]] || annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [annotationView setCanShowCallout:YES];
            
            UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            removeButton.frame = CGRectMake(.0f, .0f, 23.0f, 23.0f);
            [removeButton setImage:[UIImage imageNamed:@"DeleteGeotification"] forState:UIControlStateNormal];
            [annotationView setLeftCalloutAccessoryView:removeButton];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 1.0f;
        circleRenderer.strokeColor = [UIColor purpleColor];
        circleRenderer.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:.4f];
        return circleRenderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    Geotification *geotification = (Geotification *) view.annotation;
    [self stopMonitoringGeotification:geotification];
    [self removeGeotification:geotification];
    [self saveAllGeotifications];
}

#pragma mark - Map overlay functions

- (void)addRadiusOverlayForGeotification:(Geotification *)geotification{
    if (self.mapView) [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:geotification.coordinate radius:geotification.radius]];
}

- (void)removeRadiusOverlayForGeotification:(Geotification *)geotification{
    if (self.mapView){
        NSArray *overlays = self.mapView.overlays;
        for (MKCircle *circleOverlay in overlays) {
            if ([circleOverlay isKindOfClass:[MKCircle class]]) {
                CLLocationCoordinate2D coordinate = circleOverlay.coordinate;
                if (coordinate.latitude == geotification.coordinate.latitude && coordinate.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius) {
                    [self.mapView removeOverlay:circleOverlay];
                    break;
                }
            }
        }
    }
}

#pragma mark - Other mapview functions

- (IBAction)zoomToCurrentLocation:(id)sender{
    [Utilities zoomToUserLocationInMapView:self.mapView];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self.mapView setShowsUserLocation:status==kCLAuthorizationStatusAuthorizedAlways];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"Monitoring failed for region with identifer: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Manager failed with the following error: %@", error);
}

#pragma mark - Geotifications

- (CLCircularRegion *)regionWithGeotification:(Geotification *)geotification{
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:geotification.coordinate radius:geotification.radius identifier:geotification.identifier];
    [region setNotifyOnEntry:geotification.eventType==OnEntry];
    [region setNotifyOnExit:!region.notifyOnEntry];
    
    return region;
}

- (void)startMonitoringGeotification:(Geotification *)geotification{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        [Utilities showSimpleAlertWithTitle:@"Error" message:@"Geofencing is not supported on this device!" viewController:self];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [Utilities showSimpleAlertWithTitle:@"Warning" message:@"Your geotification is saved but will only be activated once you grant GeofencesTest permission to access the device location." viewController:self];
    }
    
    CLCircularRegion *region = [self regionWithGeotification:geotification];
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringGeotification:(Geotification *)geotification{
    for (CLCircularRegion *circularRegion in self.locationManager.monitoredRegions) {
        if ([circularRegion isKindOfClass:[CLCircularRegion class]]) {
            if ([circularRegion.identifier isEqualToString:geotification.identifier]) {
                [self.locationManager stopMonitoringForRegion:circularRegion];
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addGeotification"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddGeotificationViewController *vc = navigationController.viewControllers.firstObject;
        [vc setDelegate:self];
    }
}

@end
