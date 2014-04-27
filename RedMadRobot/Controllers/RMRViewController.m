//
//  RMRViewController.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRViewController.h"
#import "RMRInstagramAPIClient.h"
#import "RMRInstaUser.h"
#import "RMRImagesContainer.h"
#import "RMRCollageViewController.h"

@interface RMRViewController () <UITextFieldDelegate>

@property (nonatomic, strong) RMRInstagramAPIClient *instaClient;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) RMRImagesContainer *loadedImagesContainer;
@property (nonatomic, strong) RMRInstaUser *user;

- (IBAction)doneTapped:(id)sender;

@end

@implementation RMRViewController

- (RMRInstagramAPIClient *)instaClient
{
    if (!_instaClient) {
        _instaClient = [RMRInstagramAPIClient new];
    }
    return _instaClient;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.activityView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.doneButton.enabled = YES;
    self.usernameField.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneTapped:(id)sender
{
    [self.usernameField resignFirstResponder];
    NSString *username = self.usernameField.text;
    if (username.length) {
        [self getImagesByUserName:username];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        [self getImagesByUserName:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)getImagesByUserName:(NSString *)username
{
    self.usernameField.enabled = NO;
    self.doneButton.enabled = NO;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];

    if ([self.user.userName isEqualToString:username]) {
        [self userLoaded:self.user error:nil];
        return;
    }
    
    typeof(self) __weak wself = self;
    [self.instaClient getUserIdByUsername:username
                               completion:^(RMRInstaUser *user, NSError *error) {
                                   [wself userLoaded:user error:error];
                               }];
}

- (void)userLoaded:(RMRInstaUser *)user error:(NSError *)error
{
    if (user) {
        self.user = user;
        typeof(self) __weak wself = self;
        [self.instaClient getUserImagesByUserId:user.userId
                                    completion:^(RMRImagesContainer *container, NSError *error) {
                                        [wself userImagesLoaded:container error:error];
                                    }];
    }
    else {
        self.doneButton.enabled = YES;
        self.usernameField.enabled = YES;
        [self.activityView stopAnimating];
        [self showErrorMessage:@"Can't get user" reason:error.localizedDescription];
    }
}

- (void)userImagesLoaded:(RMRImagesContainer *)container error:(NSError *)error
{
    if (container) {
        self.loadedImagesContainer = container;
        [self goToCollageViewController];
    }
    else {
        self.doneButton.enabled = YES;
        self.usernameField.enabled = YES;
        [self.activityView stopAnimating];
        [self showErrorMessage:@"Can't get images" reason:error.localizedDescription];
    }
}

- (void)showErrorMessage:(NSString *)message reason:(NSString *)reason
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:reason?message:@"Error"
                                                    message:reason?:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)goToCollageViewController
{
    [self.activityView stopAnimating];
    [self performSegueWithIdentifier:@"RMRGoToCollageViewControllerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RMRCollageViewController *vc = [segue destinationViewController];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)];
    vc.user = self.user;
    vc.imagesContainer = self.loadedImagesContainer;
    vc.selectedImagesIndexes = indexes;
}

@end
