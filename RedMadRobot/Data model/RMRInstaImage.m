//
//  RMRMedia.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRInstaImage.h"
#import "NSURL+RMR.h"
#import "NSObject+RMR.h"

@interface RMRInstaImage()

@property (nonatomic, readwrite) NSUInteger likesCount;
@property (nonatomic, copy, readwrite) NSURL *srImage;
@property (nonatomic, copy, readwrite) NSURL *thumbnail;
@property (nonatomic, copy, readwrite) NSURL *hdImage;

@end

@implementation RMRInstaImage

+ (instancetype)imageWithExternalReperesantation:(id)exteranlRepresentation
{
    if ([exteranlRepresentation isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)exteranlRepresentation;
        if ([dict[@"type"] isEqualToString:@"image"]) {
            RMRInstaImage *image = [RMRInstaImage new];
            [self fill:&image withDictionary:dict];
            return image;
        }
    }
    return nil;
}

+ (void)fill:(RMRInstaImage *__autoreleasing*)image withDictionary:(NSDictionary *)dict
{
    if (!image) return;
    RMRInstaImage *_image = *image;
    _image.likesCount = [[dict rmr_objectForKeyPath:@"likes.count"] unsignedIntegerValue];
    
    NSString *thumbnail = [dict rmr_objectForKeyPath:@"images.thumbnail.url"];
    _image.thumbnail = [NSURL rmr_URLWithString:thumbnail];
    
    NSString *srImage = [dict rmr_objectForKeyPath:@"images.low_resolution.url"];
    _image.srImage = [NSURL rmr_URLWithString:srImage];
    
    NSString *hdImage = [dict rmr_objectForKeyPath:@"images.standard_resolution.url"];
    _image.hdImage = [NSURL rmr_URLWithString:hdImage];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[RMRInstaImage class]]) {
        return NO;
    }
    return [self isEqualToImage:object];
}

- (BOOL)isEqualToImage:(RMRInstaImage *)image
{
    if (!image) {
        return NO;
    }
    
    NSArray *conditionas = @[@([_thumbnail isEqual:image.thumbnail]),
                             @([_srImage isEqual:image.srImage]),
                             @([_hdImage isEqual:image.hdImage]),
                             @(_likesCount == image.likesCount)];
    return ![conditionas containsObject:@(NO)];
}

- (NSUInteger)hash {
    return [self.srImage hash] ^ [self.thumbnail hash] ^ [self.hdImage hash] ^ self.likesCount;
}

@end
