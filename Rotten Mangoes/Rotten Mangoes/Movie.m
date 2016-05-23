//
//  Movie.m
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (instancetype)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _title = [data valueForKey:@"title"];
        _synopsis = [data valueForKey:@"synopsis"];
        _ratings = [data valueForKey:@"ratings"];
        
        NSDictionary *posters = [data valueForKey:@"posters"];
        
        _posterUrl = [NSURL URLWithString:[posters valueForKey:@"original"]];

    }
    return self;
}

@end
