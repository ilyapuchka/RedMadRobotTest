//
//  RMRImagesLoader.m
//  RedMadRobot
//
//  Created by Пучка Илья on 26.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRImagesLoader.h"

@interface RMRImagesLoader()

@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, strong, readwrite) NSMutableArray *loadedImages;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation RMRImagesLoader

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[self sessionConfiguration]
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    return _session;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"image/jpeg"}];
    return sessionConfig;
}

- (void)loadImagesWithURLs:(NSArray *)urls completion:(void (^)(NSArray *))completion
{
    if (!completion) return;
    
    self.finished = NO;
    self.loadedImages = [@[] mutableCopy];
    typeof(self) __weak wself = self;
    typeof(completion) internalCompletion = ^(NSArray *images) {
        wself.finished = YES;
        if (completion) completion(images);
    };
    
    NSEnumerator *enumerator = [urls objectEnumerator];
    imagesLeft = urls.count;
    [self loadImageIfNeededWithEnumerator:enumerator finished:internalCompletion];
}

static NSUInteger imagesLeft;

- (void)loadImageIfNeededWithEnumerator:(NSEnumerator *)enumerator finished:(void (^)(NSArray *))finished
{
    typeof(self) __weak wself = self;
    NSURL *nextURL = enumerator.nextObject;
    if (nextURL) {
        [self loadImageWithURL:nextURL completion:^(UIImage *image) {
            if (image) [wself.loadedImages addObject:image];
            imagesLeft--;
            if (imagesLeft == 0) finished(wself.loadedImages);
        }];
        [self loadImageIfNeededWithEnumerator:enumerator finished:finished];
    }
}

- (void)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *))completion
{
    if (!completion || !url) return;
    
    [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data scale:[[UIScreen mainScreen] scale]];
            completion(image);
        });
    }] resume];
}

- (void)cancelLoading
{
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)dealloc
{
    [self cancelLoading];
}

@end
