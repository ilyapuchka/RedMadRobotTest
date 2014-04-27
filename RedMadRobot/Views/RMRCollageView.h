//
//  RMRCollageView.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMRCollageView : UIImageView

- (instancetype)initWithItemSize:(CGSize)itemSize itemsCount:(NSUInteger)itemsCount;
- (void)setImages:(NSArray *)images;

@end
