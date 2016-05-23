//
//  MovieDetailViewController.m
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "Movie.h"

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *synopsis;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupView {
    self.posterImageView.image = self.movie.poster;
    self.synopsis.text = self.movie.synopsis;
    self.ratingLabel.text = [self.movie.ratings valueForKey:@"critics_rating"];
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
