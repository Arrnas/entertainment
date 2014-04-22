//
//  CRMotionView.h
//  CRMotionView
//
//  Created by Christian Roman on 06/02/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class fbpageViewController;

@interface CRMotionView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter = isMotionEnabled) BOOL motionEnabled;
@property fbpageViewController *parent;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (instancetype)initWithFrame:(CGRect)frame parent:(fbpageViewController *)parent;

@end
