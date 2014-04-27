//
//  RMRCollageView.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRCollageView.h"

@interface RMRCollageView()

@property (nonatomic) CGFloat padding;

@end

@implementation RMRCollageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithItemSize:(CGSize)itemSize itemsCount:(NSUInteger)itemsCount
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup];
        
        CGSize size = [self sizeToFitItemSize:itemSize itemsCount:itemsCount];
        self.frame = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

- (CGSize)sizeToFitItemSize:(CGSize)itemSize itemsCount:(NSUInteger)itemsCount
{
    int dv = (int)sqrt(itemsCount);
    CGFloat width = itemSize.width * dv + self.padding * (dv + 1);
    CGFloat height = itemSize.height * dv + self.padding * (dv + 1);
    return CGSizeMake(width, height);
}

- (CGSize)itemSizeToFitItemsCount:(NSUInteger)itemsCount
{
    int dv = (int)sqrt(itemsCount);
    CGFloat width = (self.bounds.size.width - self.padding * (dv + 1))/dv;
    CGFloat height = (self.bounds.size.height - self.padding * (dv + 1))/dv;
    return CGSizeMake(width, height);
}

- (CGSize)itemOffsetForItemAtIndex:(NSUInteger)itemIndex itemSize:(CGSize)itemSize itemsCount:(NSUInteger)itemsCount
{
    int dv = (int)sqrt(itemsCount);
    CGFloat dx = (itemIndex % dv) * itemSize.width + self.padding * ((itemIndex % dv) + 1);
    CGFloat dy = (itemIndex / dv) * itemSize.height + self.padding * ((itemIndex / dv) + 1);
    return CGSizeMake(dx, dy);
}

- (void)setup
{
    self.padding = 5;
}

- (void)setImages:(NSArray *)images
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = [self drawInContext:context images:images];
    UIGraphicsEndImageContext();
    
    self.image = image;
}

- (UIImage *)drawInContext:(CGContextRef)context images:(NSArray *)images
{
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, self.bounds);

    CGSize imageItemSize = [self itemSizeToFitItemsCount:images.count];
    __block CGRect rect = CGRectMake(0, 0, imageItemSize.width, imageItemSize.height);
    
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        CGSize offset = [self itemOffsetForItemAtIndex:idx itemSize:imageItemSize itemsCount:images.count];
        [image drawInRect:CGRectOffset(rect, offset.width, offset.height)];
    }];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

@end
