//
//  RMRCollectionViewCell.h
//  RedMadRobot
//
//  Created by Пучка Илья on 26.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMRCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSURL *imageURL;

@end
