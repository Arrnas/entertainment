//
//  ViewController.m
//  fb
//
//  Created by Arnas on 17/03/14.
//  Copyright (c) 2014 Arnas. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MWWindow.h"
#import "fbpageViewController.h"

@interface ViewController ()

@property (nonatomic, strong) MWWindow *nextWindow;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
    FBLoginView *loginView = [[FBLoginView alloc] init];
    // Align the button in the center horizontally
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 150);
    //loginView.readPermissions = @[@"basic_info", @"email", @"user_likes",@"rsvp_event"];
    //loginView.publishPermissions = @[@"rsvp_event"];
    //[self.view addSubview:loginView];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    fbpageViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"fbpageViewController"];
//    _nextWindow = [[MWWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    _nextWindow.windowLevel = UIWindowLevelStatusBar;
//    _nextWindow.rootViewController = myController;
//    [_nextWindow makeKeyAndVisible];
//    [_nextWindow nextWindowLowered];
}
- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"fbpageViewController"];
    self.topMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"nothing"];
    self.bottomMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"nothing"];
    self.backgroundImage = [UIImage imageNamed:@"flowa.jpg"];
    self.delegate = self;
    self.panGestureEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonHit:(id)sender {
    //[self performSegueWithIdentifier:@"fbpage" sender:self];
}

@end
