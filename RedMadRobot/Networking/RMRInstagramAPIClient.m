//
//  RMRInstagramAPIClient.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRInstagramAPIClient.h"
#import "NSURL+RMR.h"
#import "RMRInstaUser.h"
#import "RMRInstaImage.h"
#import "RMRImagesContainer.h"

@interface RMRInstagramAPIClient()

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, strong) NSURLSession *session;

@end

static NSString * const kAPIHost = @"api.instagram.com";
static NSString * const kAPIScheme = @"https";

@implementation RMRInstagramAPIClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clientId = @"af34e51a747a4346b6868fae6953d04f";
    }
    return self;
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[self sessionConfiguration]
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    return _session;
}

- (void)dealloc
{
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    return sessionConfig;
}

- (void)getUserIdByUsername:(NSString *)username completion:(void (^)(RMRInstaUser *, NSError *))completion
{
    if (!username) {
        return;
    }
    NSURL *url = [self urlForAPIPath:@"users/search" queryParameters:@{@"q": username,
                                                                       @"count": @"1"}];
    typeof(self) __weak wself = self;
    [self getURL:url completion:^(NSDictionary *responseObject, NSError *error) {
        [wself processUserInfoResponse:responseObject error:error completion:completion];
    }];
}

- (void)getUserImagesByUserId:(NSString *)userId completion:(void (^)(RMRImagesContainer *, NSError *))completion
{
    if (!userId) {
        return;
    }
    
    NSURL *url = [self urlForAPIPath:[NSString stringWithFormat:@"/users/%@/media/recent", userId]
                     queryParameters:nil];
    
    [self getMoreUserImagesWithURL:url completion:completion];
}

- (void)getMoreUserImagesWithURL:(NSURL *)url completion:(void (^)(RMRImagesContainer *, NSError *))completion
{
    if (!url) {
        return;
    }
    typeof(self) __weak wself = self;
    [self getURL:url completion:^(id responseObject, NSError *error) {
        [wself processImagesResponse:responseObject error:error completion:completion];
    }];
}

#pragma mark - Response processing

- (void)processImagesResponse:(id)responseObject error:(NSError *)error completion:(void (^)(RMRImagesContainer *, NSError *))completion
{
    NSError *_error = error;
    RMRImagesContainer *container;
    if (!_error) {
        container = [RMRImagesContainer imagesContainerWithExternalReperesantation:responseObject];
    }
    
    if (!_error) {
        completion(container, nil);
    }
    else {
        completion(nil, _error);
    }
}

- (void)processUserInfoResponse:(id)responseObject error:(NSError *)error completion:(void (^)(RMRInstaUser *, NSError *))completion
{
    NSError *_error = error;
    RMRInstaUser *user;
    
    NSError *(^errorWithMessage)(NSString *) = ^(NSString *message){
        return [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: message?:@""}];
    };
    
    if (!_error) {
        NSArray *data = responseObject[@"data"];
        if ([data isKindOfClass:[NSArray class]]) {
            if (data.count) {
                user = [RMRInstaUser userWithExternalReperesantation:[data lastObject]];
            }
            else {
                _error = errorWithMessage(@"No such user");
            }
        }
        else {
            _error = errorWithMessage(@"Invalid response");
        }
    }
    
    if (!_error) {
        completion(user, nil);
    }
    else {
        completion(nil, _error);
    }
}

#pragma mark - Private

- (NSURL *)urlForAPIPath:(NSString *)path queryParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *mParameters = [parameters mutableCopy]?:[@{} mutableCopy];
    [mParameters setObject:self.clientId forKey:@"client_id"];
    NSString *mPath = [@"/v1" stringByAppendingPathComponent:path];
    return [[NSURL alloc] rmr_initWithScheme:kAPIScheme
                                        host:kAPIHost
                                        path:mPath
                                       query:mParameters];
}

- (void)getURL:(NSURL *)url completion:(void (^)(id, NSError *))completion
{
    typeof(completion) internalCompletion = ^(id responseObject, NSError *error){
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject, error);
            });
        }
    };
    
    [[self.session dataTaskWithURL:url
                 completionHandler:^(NSData *data,
                                     NSURLResponse *response,
                                     NSError *error) {
                     
                     if ([(NSHTTPURLResponse *)response statusCode] == 200 &&
                         data != nil) {
                         NSError *_error;
                         id responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:&_error];
                         if ([responseObject isKindOfClass:[NSDictionary class]]) {
                             internalCompletion(responseObject, _error);
                         }
                     }
                     else {
                         internalCompletion(nil, error);
                     }
                     
                 }] resume];
}

@end
