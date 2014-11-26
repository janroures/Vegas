//
//  KJDMapKitViewController.m
//  ChatCode
//
//  Created by Karim Mourra on 11/26/14.
//  Copyright (c) 2014 Karim. All rights reserved.
//

#import "KJDMapKitViewController.h"
#import <MapKit/MapKit.h>

@interface KJDMapKitViewController ()

@property(strong, nonatomic) MKMapView* mapView;
//@property(strong, nonatomic) MKMapView* mapView;

@property (strong,nonatomic) CLLocation *currentCoordinates;

@end

@implementation KJDMapKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDesiredAccuracy:kCLDistanceFilterNone];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager  requestWhenInUseAuthorization];
    }

    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];

    [self locationManager:self.locationManager didUpdateLocations:@[self.locationManager.location]];
    
    MKCoordinateRegion regionToDisplay = MKCoordinateRegionMakeWithDistance(self.currentCoordinates.coordinate, 10, 10);
    
    [self.mapView setRegion:regionToDisplay animated:YES];
    
    [self.view addSubview:self.mapView];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentCoordinates = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"KJD -There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated

{
    self.currentCoordinates = [[CLLocation alloc] initWithLatitude:38.8833 longitude:-77.0167];
    [self.locationManager startUpdatingLocation];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
