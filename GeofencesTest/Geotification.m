//
//  Geotification.m
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import "Geotification.h"

static NSString * kGeotificationLatitudeKey = @"latitude";
static NSString * kGeotificationLongitudeKey = @"longitude";
static NSString * kGeotificationRadiusKey = @"radius";
static NSString * kGeotificationIdentifierKey = @"identifier";
static NSString * kGeotificationNoteKey = @"note";
static NSString * kGeotificationEventTypeKey = @"eventType";

@interface Geotification ()

@end

@implementation Geotification 

- (NSString *)title{
    if (self.note.length==0) {
        return @"No Note";
    }
    return self.note;
}

- (NSString *)subtitle{
    NSString *eventTypeString = self.eventType == OnEntry ? @"On Entry" : @"On Exit";
    return [NSString stringWithFormat:@"Radius: %fm - %@", self.radius, eventTypeString];
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius identifier:(NSString *)identifier note:(NSString *)note eventType:(EventType)eventType{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.radius = radius;
        self.identifier = identifier;
        self.note = note;
        self.eventType = eventType;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        CGFloat latitude = [aDecoder decodeDoubleForKey:kGeotificationLatitudeKey];
                            CGFloat longitude = [aDecoder decodeDoubleForKey:kGeotificationLongitudeKey];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.radius = [aDecoder decodeDoubleForKey:kGeotificationRadiusKey];
        self.identifier = [aDecoder decodeObjectForKey:kGeotificationIdentifierKey];
        self.note = [aDecoder decodeObjectForKey:kGeotificationNoteKey];
        self.eventType = [aDecoder decodeIntegerForKey:kGeotificationEventTypeKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.coordinate.latitude forKey:kGeotificationLatitudeKey];
    [aCoder encodeDouble:self.coordinate.longitude forKey:kGeotificationLongitudeKey];
    [aCoder encodeDouble:self.radius forKey:kGeotificationRadiusKey];
    [aCoder encodeObject:self.identifier forKey:kGeotificationIdentifierKey];
    [aCoder encodeObject:self.note forKey:kGeotificationNoteKey];
    [aCoder encodeInteger:self.eventType forKey:kGeotificationEventTypeKey];
}

@end
