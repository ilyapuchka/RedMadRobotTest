//
//  RMRimagesContainer.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMRInstaImage.h"

@interface RMRImagesContainer : NSObject

+ (instancetype)imagesContainerWithExternalReperesantation:(id)exteranlRepresentation;

@property (nonatomic, strong, readonly) NSOrderedSet *images;
@property (nonatomic, strong, readonly) NSURL *nextURL;

- (void)appendContainer:(RMRImagesContainer *)container;

@end
