//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *bikeAnnotation;
@property CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.bikeStation.name);
    self.navigationItem.title=self.bikeStation.name;
    
    self.bikeAnnotation=[[MKPointAnnotation alloc]init];
    
    CGFloat lat=(CGFloat)[self.bikeStation.latitude floatValue];
    CGFloat longt=(CGFloat)[self.bikeStation.longitude floatValue];
    self.bikeAnnotation.title=self.bikeStation.name;
    self.bikeAnnotation.coordinate=CLLocationCoordinate2DMake(lat, longt);
    
    [self.mapView addAnnotation:self.bikeAnnotation];
    
//    //location manager
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    // scale the mapview
    CLLocationCoordinate2D centerCoordinate = self.bikeStation.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    MKCoordinateRegion region;
    region.center = centerCoordinate;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
    
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if (annotation==mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *pin=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout=YES;
    pin.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image=[UIImage imageNamed:@"bikeImage.png"];
    
    return pin;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.bikeStation.coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc]  initWithPlacemark:placemark];
    [self getDirection:mapItem];
    
}

-(void) getDirection:(MKMapItem *)destianty{
    
    MKDirectionsRequest *request=[[MKDirectionsRequest alloc]init];
    request.source=[MKMapItem mapItemForCurrentLocation];
    request.destination=destianty;
    
    MKDirections *direction=[[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes=response.routes;
        MKRoute *route=routes.firstObject;
        NSMutableString *instructions=[[NSMutableString alloc]init];
        
        for (MKRouteStep *steps in route.steps) {
            NSLog(@"%@", steps.instructions);
            [instructions appendFormat:@"%@ \n", steps.instructions];
        }
        [self showDirections:instructions];
    }];
}

-(void) showDirections:(NSString *)instructions {
    NSString *title = [NSString stringWithFormat:@"Directions to %@", self.bikeStation.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:instructions delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



@end
