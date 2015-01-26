//
//  BikeStation.h
//  CodeChallenge3
//
//  Created by Don Wettasinghe on 1/25/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface BikeStation : MKPointAnnotation

@property NSString *name;
@property NSInteger numBikes;
@property NSString *longitude;
@property NSString *latitude;
@property MKMapItem *mapItem;
@property float milesDifference;


@end
