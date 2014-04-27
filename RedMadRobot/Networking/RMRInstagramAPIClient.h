//
//  RMRInstagramAPIClient.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMRInstaUser;
@class RMRImagesContainer;

@interface RMRInstagramAPIClient : NSObject

- (void)getUserIdByUsername:(NSString *)username
                 completion:(void(^)(RMRInstaUser *user, NSError *error))completion;

- (void)getUserImagesByUserId:(NSString *)userId
                  completion:(void(^)(RMRImagesContainer *container, NSError *error))completion;

- (void)getMoreUserImagesWithURL:(NSURL *)url
                      completion:(void(^)(RMRImagesContainer *container, NSError *error))completion;

@end
