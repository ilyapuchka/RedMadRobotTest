//
//  RMRCollageViewController.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMRImagesContainer;
@class RMRInstaUser;

@interface RMRCollageViewController : UIViewController

@property (nonatomic, strong) RMRImagesContainer *imagesContainer;
@property (nonatomic, strong) RMRInstaUser *user;
@property (nonatomic, copy) NSIndexSet *selectedImagesIndexes;

@end
