//
//  RMRimagesContainer.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRImagesContainer.h"

@interface RMRImagesContainer()

@property (nonatomic, strong, readwrite) NSOrderedSet *images;
@property (nonatomic, strong, readwrite) NSURL *nextURL;

@end

@implementation RMRImagesContainer

+ (instancetype)imagesContainerWithExternalReperesantation:(id)exteranlRepresentation 
{
    if ([exteranlRepresentation isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)exteranlRepresentation;
        RMRImagesContainer *container = [RMRImagesContainer new];
        [self fill:&container withDictionary:dict];
        return container;
    }
    return nil;
}

+ (void)fill:(RMRImagesContainer *__autoreleasing *)container withDictionary:(NSDictionary *)dict
{
    if (!container) return;
    NSArray *data = dict[@"data"];
    if ([data isKindOfClass:[NSArray class]]) {
        NSMutableArray *images = [@[] mutableCopy];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RMRInstaImage *image = [RMRInstaImage imageWithExternalReperesantation:obj];
            if (image) [images addObject:image];
        }];
        
        (*container).images = [NSOrderedSet orderedSetWithArray:images];
        (*container).nextURL = [NSURL URLWithString:dict[@"pagination"][@"next_url"]];
    }
    else {
        *container = nil;
    }
}

- (void)appendContainer:(RMRImagesContainer *)container
{
    NSMutableOrderedSet *mImages = [self.images mutableCopy];
    [mImages addObjectsFromArray:container.images.array];
    self.images = [mImages copy];
    self.nextURL = container.nextURL;
}

@end
