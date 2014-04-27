//
//  RMRCollageViewController.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRCollageViewController.h"
#import "RMRCollageView.h"
#import "RMRImagesLoader.h"
#import "RMRImagesContainer.h"
#import "RMRInstaImage.h"
#import "RMRImagePickerViewController.h"
#import "RMRInstaUser.h"
#import <MessageUI/MFMailComposeViewController.h>

typedef NS_ENUM(NSUInteger, RMRCollageResolution){
    RMRCollageResolutionLow,
    RMRCollageResolutionStandard,
    RMRCollageResolutionHD
};

@interface RMRCollageViewController () <RMRImagePickerViewControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) RMRImagesLoader *previewImagesProvider;
@property (nonatomic, strong) RMRImagesLoader *shareImagesProvider;
@property (nonatomic, weak) IBOutlet RMRCollageView *previewCollageView;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) UIBarButtonItem *editItem;
@property (nonatomic) BOOL needsToUpdateCollage;
@property (nonatomic) BOOL updatingCollage;

@end

@implementation RMRCollageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItemTapped:)];
    self.navigationItem.rightBarButtonItem = editItem;
    self.editItem = editItem;
    
    self.navigationController.delegate = self;
    
    self.previewImagesProvider = [RMRImagesLoader new];
    self.shareImagesProvider = [RMRImagesLoader new];
    
    [self setNeedsToUpdateCollage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if (self.previewImagesProvider.finished) self.previewImagesProvider = [RMRImagesLoader new];
    if (self.shareImagesProvider.finished) self.shareImagesProvider = [RMRImagesLoader new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = self.user.fullName;
    
    [self updateCollagePreviewIfNeeded];
}

#pragma mark - Updating collage

- (void)setNeedsToUpdateCollage
{
    self.needsToUpdateCollage = YES;
}

- (void)updateCollagePreviewIfNeeded
{
    if (self.needsToUpdateCollage && !self.updatingCollage) {
        self.updatingCollage = YES;
        self.shareButton.enabled = NO;
        self.editItem.enabled = NO;
        
        typeof(self) __weak wself = self;
        [self loadImagesForCollageView:self.previewCollageView
                        withResolution:RMRCollageResolutionLow
                            completion:^(NSArray *images){
                                [wself.previewCollageView setImages:images];
                                wself.updatingCollage = NO;
                                wself.needsToUpdateCollage = NO;
                                wself.shareButton.enabled = YES;
                                wself.editItem.enabled = YES;
                            }];
    }
}

#pragma mark -

- (void)setSelectedImagesIndexes:(NSIndexSet *)indexes
{
    NSIndexSet *validIndexes = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (idx < self.imagesContainer.images.count);
    }];
    if (![_selectedImagesIndexes isEqual:validIndexes]) {
        _selectedImagesIndexes = [validIndexes copy];
        [self setNeedsToUpdateCollage];
    }
}

- (NSUInteger)imagesCount
{
    return MIN((int)pow((int)sqrt(self.selectedImagesIndexes.count), 2), self.imagesContainer.images.count);
}

#pragma mark - Images loading

- (void)loadImagesForCollageView:(RMRCollageView *)view
                  withResolution:(RMRCollageResolution)res
                      completion:(void(^)(NSArray *))completion
{
    RMRImagesLoader *provider = [self imagesProviderForCollageView:view];
    NSString *key;
    switch (res) {
        case RMRCollageResolutionLow:
            key = NSStringFromSelector((self.imagesCount == 1)?@selector(srImage):@selector(thumbnail));
            break;
        case RMRCollageResolutionStandard:
            key = NSStringFromSelector(@selector(srImage));
            break;
        case RMRCollageResolutionHD:
            key = NSStringFromSelector(@selector(hdImage));
            break;
    }
    NSArray *images = [self mostLikedSelectedImagesURLsWithKey:key];
    images = [images objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.imagesCount)]];
    [provider loadImagesWithURLs:images completion:completion];
}

- (NSArray *)mostLikedSelectedImagesURLsWithKey:(NSString *)key
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(likesCount))
                                                               ascending:NO]];
    NSArray *sortedImages = [[self.imagesContainer.images objectsAtIndexes:self.selectedImagesIndexes] sortedArrayUsingDescriptors:sortDescriptors];
    return [sortedImages valueForKey:key];
}

- (RMRImagesLoader *)imagesProviderForCollageView:(RMRCollageView *)view
{
    if (view == self.previewCollageView) {
        return self.previewImagesProvider;
    }
    else {
        return self.shareImagesProvider;
    }
}

#pragma mark - RMRImagePickerViewControllerDelegate

- (void)imagePickerViewControllerDidFinished:(RMRImagePickerViewController *)vc
                   withSelectedImagesIndexes:(NSIndexSet *)indexes
{
    self.selectedImagesIndexes = indexes;
}

#pragma mark - Buttons events

- (IBAction)shareTapped:(id)sender
{
    self.shareButton.enabled = NO;
    self.editItem.enabled = NO;
    RMRCollageView *shareView = [[RMRCollageView alloc] initWithItemSize:CGSizeMake(320, 320)
                                                              itemsCount:self.imagesCount];
    typeof(self) __weak wself = self;
    [self loadImagesForCollageView:shareView
                    withResolution:RMRCollageResolutionHD
                        completion:^(NSArray *images){
                            [shareView setImages:images];
                            [wself presentShareControllerWithImage:shareView.image];
                            wself.shareButton.enabled = YES;
                            self.editItem.enabled = YES;
                        }];
}

- (void)presentShareControllerWithImage:(UIImage *)image
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *shareViewController = [[MFMailComposeViewController alloc] init];
        shareViewController.mailComposeDelegate = self;

        [shareViewController addAttachmentData:UIImagePNGRepresentation(image)
                                           mimeType:@"image/png"
                                           fileName:@"collage.png"];
        [shareViewController setSubject:@"Check out my cool collage!"];
        [self presentViewController:shareViewController animated:YES completion:nil];
    }
}

- (void)editItemTapped:(id)sender
{
    [self performSegueWithIdentifier:@"RMRImagePickerViewControllerModalSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RMRImagePickerViewController *vc = (RMRImagePickerViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
    vc.delegate = self;
    vc.navigationItem.title = self.navigationItem.title;
    vc.imagesContainer = self.imagesContainer;
    vc.selectedImages = self.selectedImagesIndexes;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController != self) {
        [self.previewImagesProvider cancelLoading];
        [self.shareImagesProvider cancelLoading];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
