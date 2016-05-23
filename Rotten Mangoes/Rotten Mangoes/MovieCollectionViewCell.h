//
//  MovieCollectionViewCell.h
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;

@property (nonatomic) NSURLSessionTask *task;

@end
