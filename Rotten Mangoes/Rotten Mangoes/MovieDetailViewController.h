//
//  MovieDetailViewController.h
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Movie;

@interface MovieDetailViewController : UIViewController

@property (nonatomic) Movie *movie;

-(void)setupView;

@end
