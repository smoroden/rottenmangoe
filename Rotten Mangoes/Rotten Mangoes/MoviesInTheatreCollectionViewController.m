//
//  MoviesInTheatreCollectionViewController.m
//  Rotten Mangoes
//
//  Created by Zach Smoroden on 2016-05-23.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import "MoviesInTheatreCollectionViewController.h"
#import "Movie.h"
#import "MovieCollectionViewCell.h"
#import "MovieDetailViewController.h"

#define RT_API_KEY @"&apikey=55gey28y6ygcr8fjy4ty87ek"

@interface MoviesInTheatreCollectionViewController () <UIScrollViewDelegate>

@property (nonatomic) NSMutableArray *movies;
@property (nonatomic) NSURL *nextUrl;
@property (nonatomic) BOOL hasMore;
@property (nonatomic, getter=isRefreshing) BOOL refreshing; //CR: In Objective C, consider using getter annotation for BOOL properties. This is an Objective C/Cocoa convention (it's been dropped from Swift). When setting this property, use self.refreshing, when accessing, use self.isRefreshing.

@end

@implementation MoviesInTheatreCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    

    // Do any additional setup after loading the view.
    
    self.movies = [NSMutableArray array];
    
    _hasMore = YES;

    
    [self refreshMovies];
    
    
    
    
}
//test

-(void)refreshMovies {
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.frame = self.view.frame;
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url;
    if (!self.nextUrl && self.hasMore) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?%@&page_limit=50", RT_API_KEY]];
    } else {
        url = self.nextUrl;
    }
    
    self.refreshing = YES;
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *jsonError = nil;
        
        NSDictionary *theData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        NSArray *movies = [theData valueForKey:@"movies"];
        
        //NSLog(@"%@", movies);
        
        for (NSDictionary *movie in movies) {
            [self.movies addObject:[[Movie alloc] initWithData:movie]];
        }
        
        NSDictionary *links = [theData valueForKey:@"links"];
        
        self.nextUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[links valueForKey:@"next"], RT_API_KEY]];
        self.hasMore = self.nextUrl ? YES : NO;
        
                self.refreshing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityView stopAnimating];
            [activityView removeFromSuperview];

            [self.collectionView reloadData];
            
        });
        
    }];
    
    [task resume];

}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCell" forIndexPath:indexPath];
    
    // Configure the cell
    //[cell.task cancel];
    
    Movie *movie = self.movies[indexPath.row];
    
    cell.titleLabel.text = movie.title;
    
    if(!movie.poster) {
        
        
        cell.task = [[NSURLSession sharedSession] dataTaskWithURL:movie.posterUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(data) {
                movie.poster = [UIImage imageWithData:data];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    cell.posterImageView.image = movie.poster;
                    //[self.collectionView reloadData];
                    
                });
            }
            
        }];
        
        [cell.task resume];

    }
    
    cell.posterImageView.image = movie.poster;
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(MovieCollectionViewCell*)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
    if ([segue.identifier isEqualToString:@"MovieDetail"]) {
        MovieDetailViewController *mdvc = segue.destinationViewController;
        
        mdvc.movie = self.movies[indexPath.row];
    }
    
}

#pragma mark Paging
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height)
    {
        if (!self.refreshing) {
            [self refreshMovies];
        }
        
    }
}

@end
