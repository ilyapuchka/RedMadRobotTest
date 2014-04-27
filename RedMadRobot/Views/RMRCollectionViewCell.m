//
//  RMRCollectionViewCell.m
//  RedMadRobot
//
//  Created by Пучка Илья on 26.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRCollectionViewCell.h"

@implementation RMRCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.borderColor = (self.isSelected?[UIColor redColor]:[UIColor whiteColor]).CGColor;
    self.layer.borderWidth = 2.0f;
}

- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.imageURL = nil;
}

@end
