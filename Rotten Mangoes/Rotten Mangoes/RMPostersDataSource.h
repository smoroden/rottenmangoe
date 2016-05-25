//
//  RMPostersDataSource.h
//  Rotten Mangoes
//
//  Created by BozBook on 2016-05-25.
//  Copyright © 2016 Zach Smoroden. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit.UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface RMPostersDataSource : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)posterForURL:(NSURL *)posterURL
         withPartial:(void (^)(UIImage * partialImage))partialBlock
             success:(void (^)(UIImage * image))successBlock
             failure:(void (^)(NSError * _Nullable error))failureBlock;

- (void)resumeDownloadForPoster:(NSURL *)posterURL;
- (void)pauseDownloadForPoster:(NSURL *)posterURL;

@end

NS_ASSUME_NONNULL_END
