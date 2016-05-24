//
//  MovieMapViewController.m
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-24.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import "MovieMapViewController.h"
#import <MapKit/MapKit.h>
#import "Movie.h"
#import "Theatre.h"

@interface MovieMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *lastLocation;
@property (nonatomic) NSString *postalCode;

@property (nonatomic) NSString *api;

@property (nonatomic) NSMutableArray *theatres;

@end

@implementation MovieMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.api = @"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?";
    
    self.theatres = [NSMutableArray array];

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"did get auth status %i", status);
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    if(!self.lastLocation) {
        // Zoom to current location only the first time we get it
        MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, span);
        
        [self.mapView setRegion:region animated:YES];
        
        // now we find the postal code
        CLGeocoder *coder = [[CLGeocoder alloc] init];
        
        [coder reverseGeocodeLocation:currentLocation completionHandler:^
         (NSArray<CLPlacemark *> *placemarks, NSError *error) {
             CLPlacemark *place = [placemarks firstObject];
             
             self.postalCode = place.postalCode;
             
             [self findTheatres];
             
        }];
        
        
    }
    
    self.lastLocation = currentLocation;

}

-(void)findTheatres {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@address=%@&movie=%@", self.api, self.postalCode, [self.movie.title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *jsonError = nil;
        
        NSDictionary *theData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        NSArray *theTheatres = [theData valueForKey:@"theatres"];
        
        for (NSDictionary *theatre in theTheatres) {
            [self.theatres addObject:[[Theatre alloc] initWithDictionary:theatre]];
        }

        [self addAnnotations];
        
    }];
    [task resume];
}

-(void) addAnnotations {
    for (Theatre *theatre in self.theatres) {
        MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc] init];
        newAnnotation.title = theatre.name;
        newAnnotation.subtitle = theatre.address;
        newAnnotation.coordinate = theatre.location;
        
        [self.mapView addAnnotation:newAnnotation];

    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        pin.pinTintColor = [UIColor purpleColor];
        pin.canShowCallout = YES;
    }
    
    
    
    return pin;
}



@end
