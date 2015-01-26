//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "BikeStation.h"
#import "MapViewController.h"

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *bikeStations;
@property BikeStation  *selectedRow;
@property CLLocationManager *locationManager;
@property NSString *searchFilter;
@property CLLocation *placeMarkLocation;
@property NSMutableArray *sortedBikeArray;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    self.bikeStations=[[NSMutableArray alloc]init];
    self.sortedBikeArray=[[NSMutableArray alloc]init];
    
    [self getBikeStationlist];
    
    [self.tableView reloadData];
}

-(void)getBikeStationlist{
    
    NSURL *url=[NSURL URLWithString:@"http://www.bayareabikeshare.com/stations/json"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSDictionary *bikeDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        
        NSArray *bikes=[bikeDic objectForKey:@"stationBeanList"];
        
        for (NSDictionary *bData in bikes) {
            BikeStation *bikeStation = [BikeStation new];
            bikeStation.name = [bData objectForKey:@"stAddress1"];
            bikeStation.numBikes = [[bData objectForKey:@"availableBikes"] intValue];
            bikeStation.latitude = [bData objectForKey:@"latitude"];
            bikeStation.longitude = [bData objectForKey:@"longitude"];
            // set the coordinates
            CGFloat longFloat = (CGFloat)[bikeStation.longitude floatValue];
            CGFloat latFloat = (CGFloat)[bikeStation.latitude floatValue];
            bikeStation.coordinate = CLLocationCoordinate2DMake(latFloat,longFloat);
            
            [self.bikeStations addObject:bikeStation];
        }
        
        [self.tableView reloadData];
        [self sortBikeStations];

        
    }];


}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchFilter = self.searchBar.text;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchBar.showsCancelButton = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    // loop through stations and remove ones not in search
    for (BikeStation *bStation in self.bikeStations) {
        // make case insensitve
        NSString *lowerSearch = [self.searchBar.text lowercaseString];
        NSString *lowerStat = [bStation.name lowercaseString];
        if ([lowerStat rangeOfString:lowerSearch].location == NSNotFound) {
            if ([self.bikeStations containsObject:bStation]) {
                [self.bikeStations removeObject:bStation];
            }
        }
    }
    [self.tableView reloadData];
}

-(void) sortBikeStations {
    for (BikeStation *bStation in self.bikeStations) {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:bStation.coordinate addressDictionary:nil];
        // get the miles difference
        CLLocationDistance metersAway = [placemark.location distanceFromLocation:self.placeMarkLocation];
        float milesDifference = metersAway / 1609.34;
        bStation.milesDifference = milesDifference;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"milesDifference" ascending:true];
    NSArray *sortedArray = [self.bikeStations sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.bikeStations = [NSMutableArray arrayWithArray:sortedArray];
    self.sortedBikeArray = [NSMutableArray arrayWithArray:self.bikeStations];
    
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 1000 && location.verticalAccuracy < 1000) {
            self.placeMarkLocation = location;
            [self.locationManager stopUpdatingLocation];
            [self reverseGeocode:location];
            break;
        }
    }
}

- (void) reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        self.placeMarkLocation = placemark.location;
        [self getBikeStationlist];
    }];
    
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedBikeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    BikeStation *bStations=[self.sortedBikeArray objectAtIndex:indexPath.row];
    cell.textLabel.text=bStations.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Available bikes: %ld" ,(long)bStations.numBikes];
    
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    MapViewController *mVC=[segue destinationViewController];
    mVC.bikeStation=[self.bikeStations objectAtIndex:[self.tableView indexPathForSelectedRow].row];
}




@end
