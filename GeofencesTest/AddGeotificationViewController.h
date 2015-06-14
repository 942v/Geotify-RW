//
//  AddGeotificationViewController.h
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geotification.h"

@import MapKit;

@protocol AddGeotificationsViewControllerDelegate;

@interface AddGeotificationViewController : UITableViewController

@property (nonatomic, strong) id <AddGeotificationsViewControllerDelegate> delegate;

@end

@protocol AddGeotificationsViewControllerDelegate <NSObject>

- (void)addGeotificationViewController:(AddGeotificationViewController *)controller didAddCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius identifier:(NSString *)identifier note:(NSString *)note eventType:(EventType)eventType;

@end