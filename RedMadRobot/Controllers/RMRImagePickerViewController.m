//
//  RMRImagePickerViewController.m
//  RedMadRobot
//
//  Created by Пучка Илья on 26.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRImagePickerViewController.h"
#import "RMRImagesContainer.h"
#import "RMRCollectionViewCell.h"
#import "RMRInstagramAPIClient.h"
#import "RMRImagesLoader.h"

@interface RMRImagePickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) RMRImagesLoader *imagesProvider;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) RMRInstagramAPIClient *instaClient;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableIndexSet *mSelectedImages;

@end

@implementation RMRImagePickerViewController

- (RMRInstagramAPIClient *)instaClient
{
    if (!_instaClient) {
        _instaClient = [RMRInstagramAPIClient new];
    }
    return _instaClient;
}
- (RMRImagesLoader *)imagesProvider
{
    if (!_imagesProvider) {
        _imagesProvider = [RMRImagesLoader new];
    }
    return _imagesProvider;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"image/jpeg"}];
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    return sessionConfig;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.allowsMultipleSelection = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.imagesProvider cancelLoading];
}

    - (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedImages:(NSMutableIndexSet *)selectedImages
{
    self.mSelectedImages = [selectedImages mutableCopy];
}

- (NSIndexSet *)selectedImages
{
    return [self.mSelectedImages copy];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesContainer.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RMRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RMRCollectionViewCell class]) forIndexPath:indexPath];
    [self collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
         configureCell:(RMRCollectionViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self.imagesContainer.images valueForKey:NSStringFromSelector(@selector(hdImage))][indexPath.item];
    if ([self.selectedImages containsIndex:indexPath.item]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    else {
        cell.selected = NO;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    if (![url isKindOfClass:[NSNull class]]) {
        cell.imageURL = url;
        typeof(cell) __weak wcell = cell;
        [self.imagesProvider loadImageWithURL:url completion:^(UIImage *image) {
            if ([wcell.imageURL isEqual:url]) {
                wcell.imageView.image = image;
            }
        }];
    }
    [cell setNeedsLayout];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RMRCollectionViewCell *cell = (RMRCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.mSelectedImages addIndex:indexPath.item];
    [cell setNeedsLayout];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RMRCollectionViewCell *cell = (RMRCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.mSelectedImages removeIndex:indexPath.item];
    [cell setNeedsLayout];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self loadMoreImages];
    }
}

- (void)loadMoreImages
{
    if (!self.isLoading) {
        self.isLoading = YES;
        [self.instaClient getMoreUserImagesWithURL:self.imagesContainer.nextURL
                                        completion:^(RMRImagesContainer *container, NSError *error) {
                                            self.isLoading = NO;
                                            [self updateCollectionsViewWithNewImages:container];
                                        }];
    }
}

- (void)updateCollectionsViewWithNewImages:(RMRImagesContainer *)container
{
    if (!container) {
        return;
    }
    
    NSUInteger countBeforeUpdate = self.imagesContainer.images.count;
    [self.imagesContainer appendContainer:container];
    NSUInteger countAfterUpdate = self.imagesContainer.images.count;
    NSMutableArray *indexPaths = [@[] mutableCopy];
    for (NSUInteger i = countBeforeUpdate; i < countAfterUpdate; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    } completion:nil];
}

- (IBAction)saveTapped:(id)sender
{
    [self.delegate imagePickerViewControllerDidFinished:self
                              withSelectedImagesIndexes:self.selectedImages];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
