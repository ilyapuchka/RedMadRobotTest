//
//  RMRMedia.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMRInstaImage : NSObject

+ (instancetype)imageWithExternalReperesantation:(id)exteranlRepresentation;

@property (nonatomic, readonly) NSUInteger likesCount;
@property (nonatomic, copy, readonly) NSURL *srImage;
@property (nonatomic, copy, readonly) NSURL *hdImage;
@property (nonatomic, copy, readonly) NSURL *thumbnail;

@end
