//
//  MovieCollectionViewCell.m
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import "MovieCollectionViewCell.h"

@implementation MovieCollectionViewCell

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.task cancel];
//    self.task = nil;
}

@end
