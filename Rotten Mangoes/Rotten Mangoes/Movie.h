//
//  Movie.h
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Movie : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) UIImage *poster;
@property (nonatomic) NSString *synopsis;
@property (nonatomic) NSDictionary *ratings;

@property (nonatomic) NSURL *posterUrl;

-(instancetype)initWithData:(NSDictionary *)data;

@end
