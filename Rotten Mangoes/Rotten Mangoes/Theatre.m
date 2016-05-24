//
//  Theatre.m
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-24.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import "Theatre.h"

@implementation Theatre

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(!self)
        return nil;
    
    _address = [dictionary valueForKey:@"address"];
    
    CLLocationDegrees lat = [[dictionary valueForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[dictionary valueForKey:@"lng"] doubleValue];
    _location = CLLocationCoordinate2DMake(lat, lng);
    
    _name = [dictionary valueForKey:@"name"];
    
    return self;
}

@end
