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
#import "TheatreCell.h"

#define SHOWTIME_API_KEY @"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?"

static NSString * const kTheatreAnnotationViewReuseIdentifier = @"Pin";

@interface MovieMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *lastLocation;
@property (nonatomic) NSString *postalCode;


@property (nonatomic) NSMutableArray *theatres;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomOfButtonConstraint;

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
- (IBAction)toggleTheatreList:(UIButton *)sender {
    
    [UIView animateWithDuration:0.7 animations:^{
        if (self.bottomOfButtonConstraint.constant == 0) {
            self.bottomOfButtonConstraint.constant = self.view.frame.size.height / 2;
        } else {
            self.bottomOfButtonConstraint.constant = 0;
        }
        
        [self.view layoutIfNeeded];
    }];
    
}

-(void)findTheatres {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@address=%@&movie=%@", SHOWTIME_API_KEY, self.postalCode, [self.movie.title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *jsonError = nil;
        
        if (data) {
            NSDictionary *theData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSArray *theTheatres = [theData valueForKey:@"theatres"];
            
            // To make sure that we don't have multiples of the same theatre we put the names into a set
            NSMutableSet *theatreSet = [NSMutableSet set];
            
            for (NSDictionary *theatre in theTheatres) {
                Theatre *new = [[Theatre alloc] initWithDictionary:theatre];
                
                // Only if the set doesn't contain the name already do we add the new theatre
                if(![theatreSet containsObject:new.name]) {
                    [self.theatres addObject:new];
                    [theatreSet addObject:new.name];
                }
                
            }
            
            NSLog(@"The theatres: %@", theTheatres);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            [self addAnnotations];
            
        }
        
        
    }];
    [task resume];
}

-(void) addAnnotations {
    NSMutableArray * annotations = [NSMutableArray array];
    
    for (Theatre *theatre in self.theatres) {
        MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc] init];
        newAnnotation.title = theatre.name;
        newAnnotation.subtitle = theatre.address;
        newAnnotation.coordinate = theatre.location;
        
        [annotations addObject:newAnnotation];
    }
    
    //CR: Consider batch-adding annotations after looping through all theatres: If you have, say, over 100 annotations, and you add them one by one, it's possible that MKMapView could handle them more efficiently if you batch-add annotations.
    [self.mapView addAnnotations:annotations];
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    //CR: Ensure you are creating annotation views for annotations that need them. Also, make sure you are creating the correct type of annotation views for a given annotation.
    // For example, you may want to instantiate a custom RMTheatreAnnotationView only for RMTheatreAnnotation instances.
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        //CR: Try to use constants for reuse identifiers.
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kTheatreAnnotationViewReuseIdentifier];
        
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:kTheatreAnnotationViewReuseIdentifier];
            pin.pinTintColor = [UIColor purpleColor];
            pin.canShowCallout = YES;
        }
        
        return pin;
    }
    
    return nil;
}

#pragma mark UITableView methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TheatreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TheatreCell" forIndexPath:indexPath];
    
    Theatre *theatre = self.theatres[indexPath.row];
    
    cell.nameLabel.text = theatre.name;
    cell.addressLabel.text = theatre.address;
    
    CGFloat distance = [self.lastLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:theatre.location.latitude longitude:theatre.location.longitude]]/1000;
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.1fkm",distance];
    //theatre.location
    
    
    return cell;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.theatres.count;
}



@end
