//
//  RMRImagePickerViewController.h
//  RedMadRobot
//
//  Created by Пучка Илья on 26.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RMRImagePickerViewControllerDelegate;
@class RMRImagesContainer;

@interface RMRImagePickerViewController : UIViewController

@property (nonatomic, weak) id<RMRImagePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) RMRImagesContainer *imagesContainer;
@property (nonatomic, strong) NSIndexSet *selectedImages;

@end

@protocol RMRImagePickerViewControllerDelegate <NSObject>

@required
- (void)imagePickerViewControllerDidFinished:(RMRImagePickerViewController *)vc
                   withSelectedImagesIndexes:(NSIndexSet *)indexes;

@end
