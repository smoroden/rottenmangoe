//
//  Theatre.h
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-24.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Theatre : NSObject

@property (nonatomic) NSString *address;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) NSString *name;


-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
