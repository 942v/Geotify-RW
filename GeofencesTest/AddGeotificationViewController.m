//
//  AddGeotificationViewController.m
//  GeofencesTest
//
//  Created by Guillermo Saenz on 6/14/15.
//  Copyright (c) 2015 Property Atomic Strong SAC. All rights reserved.
//

#import "AddGeotificationViewController.h"

#import "Utilities.h"

@interface AddGeotificationViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *eventTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AddGeotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItems = @[self.addButton, self.zoomButton];
    self.addButton.enabled = false;
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender{
    self.addButton.enabled = !(self.radiusTextField.text.length==0) && !(self.noteTextField.text.length==0);
}

- (IBAction)onCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onAdd:(id)sender{
    CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    CGFloat radius = self.radiusTextField.text.floatValue;
    NSString *identifier = [[NSUUID new] UUIDString];
    NSString *note = self.noteTextField.text;
    EventType eventType = (self.eventTypeSegmentedControl.selectedSegmentIndex == 0) ? OnEntry : OnExit;
    [self.delegate addGeotificationViewController:self didAddCoordinate:coordinate radius:radius identifier:identifier note:note eventType:eventType];
}

- (IBAction)onZoomToCurrentLocation:(id)sender{
    [Utilities zoomToUserLocationInMapView:self.mapView];
}

@end
