//
//  Geotification.h
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;
@import CoreLocation;

typedef enum : NSInteger {
    OnEntry = 0,
    OnExit
} EventType;

@interface Geotification : NSObject <NSCoding, MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, assign) EventType eventType;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius identifier:(NSString *)identifier note:(NSString *)note eventType:(EventType)eventType;

@end