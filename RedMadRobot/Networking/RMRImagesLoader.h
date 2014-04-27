//
//  RMRImagesLoader.h
//  RedMadRobot
//
//  Created by Пучка Илья on 26.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMRImagesLoader : NSObject

- (void)loadImagesWithURLs:(NSArray *)urls completion:(void(^)(NSArray *images))completion;
- (void)loadImageWithURL:(NSURL *)url completion:(void(^)(UIImage *image))completion;

- (void)cancelLoading;

@property (nonatomic, readonly) BOOL finished;

@end
