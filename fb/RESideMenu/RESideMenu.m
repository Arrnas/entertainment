//
// REFrostedViewController.m
// RESideMenu
//
// Copyright (c) 2013-2014 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RESideMenu.h"
#import "UIViewController+RESideMenu.h"
#import "RECommonFunctions.h"

@interface RESideMenu ()

@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) BOOL topMenuVisible;
@property (assign, readwrite, nonatomic) BOOL bottomMenuVisible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView *contentViewContainer;
@property (assign, readwrite, nonatomic) BOOL didNotifyDelegate;

@end

@implementation RESideMenu

#pragma mark -
#pragma mark Instance lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit
{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    
    _animationDuration = 0.35f;
    _interactivePopGestureRecognizerEnabled = YES;
  
    _menuViewControllerTransformation = CGAffineTransformMakeScale(1.5f, 1.5f);
    
    _scaleContentView = YES;
    _scaleBackgroundImageView = YES;
    _scaleMenuView = YES;
    
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = -15;
    _parallaxMenuMaximumRelativeValue = 15;
    _parallaxContentMinimumRelativeValue = -25;
    _parallaxContentMaximumRelativeValue = 25;
    
    _bouncesHorizontally = YES;
    
    _panGestureEnabled = YES;
    _panFromEdge = YES;
    _panFromTop = YES;
    _panMinimumOpenThreshold = 60.0;
    
    _contentViewShadowEnabled = NO;
    _contentViewShadowColor = [UIColor blackColor];
    _contentViewShadowOffset = CGSizeZero;
    _contentViewShadowOpacity = 0.4f;
    _contentViewShadowRadius = 8.0f;
    _contentViewInLandscapeOffsetCenterX = 30.f;
    _contentViewInPortraitOffsetCenterX  = 30.f;
    _contentViewPercentHidden = 80.f;
    _contentViewScaleValue = 0.7f;
}

#pragma mark -
#pragma mark Public methods

- (id)initWithContentViewController:(UIViewController *)contentViewController topMenuViewController:(UIViewController *)topMenuViewController bottomMenuViewController:(UIViewController *)bottomMenuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _topMenuViewController = topMenuViewController;
        _bottomMenuViewController = bottomMenuViewController;
    }
    return self;
}

- (void)presentTopMenuViewController
{
    [self __presentMenuViewContainerWithMenuViewController:self.topMenuViewController];
    [self __showTopMenuViewController];
}

- (void)presentBottomMenuViewController
{
    [self __presentMenuViewContainerWithMenuViewController:self.bottomMenuViewController];
    [self __showBottomMenuViewController];
}

- (void)hideMenuViewController
{
    [self __hideMenuViewControllerAnimated:YES];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        [self addChildViewController:contentViewController];
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewContainer.bounds;
        [self.contentViewContainer addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self __hideViewController:self.contentViewController];
            [contentViewController didMoveToParentViewController:self];
            _contentViewController = contentViewController;
            [self __updateContentViewShadow];
            
            if (self.visible) {
                [self __addContentViewControllerMotionEffects];
            }
        }];
    }
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.topMenuViewController) {
        [self addChildViewController:self.topMenuViewController];
        self.topMenuViewController.view.frame = self.view.bounds;
        self.topMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.topMenuViewController.view];
        [self.topMenuViewController didMoveToParentViewController:self];
    }
    
    if (self.bottomMenuViewController) {
        [self addChildViewController:self.bottomMenuViewController];
        self.bottomMenuViewController.view.frame = self.view.bounds;
        self.bottomMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.bottomMenuViewController.view];
        [self.bottomMenuViewController didMoveToParentViewController:self];
    }
    
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    [self __addMenuViewControllerMotionEffects];
    
    if (self.panGestureEnabled) {
        self.view.multipleTouchEnabled = NO;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(__panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    [self __updateContentViewShadow];
}

#pragma mark -
#pragma mark Private methods

- (void)__presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
    }
    self.menuViewContainer.frame = self.view.bounds;
    if (self.scaleMenuView) {
        self.menuViewContainer.transform = self.menuViewControllerTransformation;
    }
    self.menuViewContainer.alpha = 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)__showTopMenuViewController
{
    if (!self.topMenuViewController) {
        return;
    }
    self.topMenuViewController.view.hidden = NO;
    self.bottomMenuViewController.view.hidden = YES;
    [self.view.window endEditing:YES];
    [self __addContentButton];
    [self __updateContentViewShadow];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }

        CGFloat zeroPercentHidden = CGRectGetHeight(self.view.frame)-(CGRectGetHeight(self.contentViewContainer.frame)/2.0);
        CGFloat yHidden = zeroPercentHidden + CGRectGetHeight(self.contentViewContainer.frame)/100.0*self.contentViewPercentHidden;
        self.contentViewContainer.center = CGPointMake(self.contentViewContainer.center.x, yHidden);
        self.menuViewContainer.alpha = 1.0f;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            
    } completion:^(BOOL finished) {
        [self __addContentViewControllerMotionEffects];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.topMenuViewController];
        }
        
        self.visible = YES;
        self.topMenuVisible = YES;
    }];
    
    [self __statusBarNeedsAppearanceUpdate];
}

- (void)__showBottomMenuViewController
{
    if (!self.bottomMenuViewController) {
        return;
    }
    self.topMenuViewController.view.hidden = YES;
    self.bottomMenuViewController.view.hidden = NO;
    [self.view.window endEditing:YES];
    [self __addContentButton];
    [self __updateContentViewShadow];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        CGFloat zeroPercentHidden = (CGRectGetHeight(self.contentViewContainer.frame)/2.0);
        CGFloat yHidden = zeroPercentHidden - CGRectGetHeight(self.contentViewContainer.frame)/100.0*self.contentViewPercentHidden;
        self.contentViewContainer.center = CGPointMake(self.contentViewContainer.center.x, yHidden);
        self.menuViewContainer.alpha = 1.0f;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        if (!self.bottomMenuVisible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.bottomMenuViewController];
        }
        
        self.visible = !(self.contentViewContainer.frame.size.width == self.view.bounds.size.width && self.contentViewContainer.frame.size.height == self.view.bounds.size.height && self.contentViewContainer.frame.origin.x == 0 && self.contentViewContainer.frame.origin.y == 0);
        self.bottomMenuVisible = self.visible;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self __addContentViewControllerMotionEffects];
    }];
    
    [self __statusBarNeedsAppearanceUpdate];
}

- (void)__hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)__hideMenuViewControllerAnimated:(BOOL)animated
{
    BOOL bottomMenuVisible = self.bottomMenuVisible;
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:bottomMenuVisible ? self.bottomMenuViewController : self.topMenuViewController];
    }
    
    self.visible = NO;
    self.topMenuVisible = NO;
    self.bottomMenuVisible = NO;
    [self.contentButton removeFromSuperview];
    
    __typeof (self) __weak weakSelf = self;
    void (^animationBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.contentViewContainer.transform = CGAffineTransformIdentity;
        strongSelf.contentViewContainer.frame = strongSelf.view.bounds;
        if (strongSelf.scaleMenuView) {
            strongSelf.menuViewContainer.transform = strongSelf.menuViewControllerTransformation;
        }
        strongSelf.menuViewContainer.alpha = 0;
        if (strongSelf.scaleBackgroundImageView) {
            strongSelf.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
        }
        if (strongSelf.parallaxEnabled) {
            IF_IOS7_OR_GREATER(
               for (UIMotionEffect *effect in strongSelf.contentViewContainer.motionEffects) {
                   [strongSelf.contentViewContainer removeMotionEffect:effect];
               }
            );
        }
    };
    void (^completionBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!strongSelf.visible && [strongSelf.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController:bottomMenuVisible ? strongSelf.bottomMenuViewController : strongSelf.topMenuViewController];
        }
    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
    [self __statusBarNeedsAppearanceUpdate];
}

- (void)__addContentButton
{
    if (self.contentButton.superview)
        return;

    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewContainer.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentButton];
}

- (void)__statusBarNeedsAppearanceUpdate
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (void)__updateContentViewShadow
{
    if (self.contentViewShadowEnabled) {
        CALayer *layer = self.contentViewContainer.layer;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
        layer.shadowPath = path.CGPath;
        layer.shadowColor = self.contentViewShadowColor.CGColor;
        layer.shadowOffset = self.contentViewShadowOffset;
        layer.shadowOpacity = self.contentViewShadowOpacity;
        layer.shadowRadius = self.contentViewShadowRadius;
    }
}

#pragma mark -
#pragma mark iOS 7 Motion Effects (Private)

- (void)__addMenuViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
           for (UIMotionEffect *effect in self.menuViewContainer.motionEffects) {
               [self.menuViewContainer removeMotionEffect:effect];
           }
           UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
           interpolationHorizontal.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
           interpolationHorizontal.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);
           
           UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
           interpolationVertical.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
           interpolationVertical.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);
           
           [self.menuViewContainer addMotionEffect:interpolationHorizontal];
           [self.menuViewContainer addMotionEffect:interpolationVertical];
        );
    }
}

- (void)__addContentViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
            for (UIMotionEffect *effect in self.contentViewContainer.motionEffects) {
               [self.contentViewContainer removeMotionEffect:effect];
            }
            [UIView animateWithDuration:0.2 animations:^{
                UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                interpolationHorizontal.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
                interpolationHorizontal.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);

                UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                interpolationVertical.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
                interpolationVertical.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);

                [self.contentViewContainer addMotionEffect:interpolationHorizontal];
                [self.contentViewContainer addMotionEffect:interpolationVertical];
            }];
        );
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    IF_IOS7_OR_GREATER(
       if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
           UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
           if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
               return NO;
           }
       }
    );
  
//    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
//        CGPoint point = [touch locationInView:gestureRecognizer.view];
//        if (point.x < 20.0 || point.x > self.view.frame.size.width - 20.0) {
//            return YES;
//        } else {
//            return NO;
//        }
//    }
    
    if (self.panFromTop && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.y < 50.0 || point.y > self.view.frame.size.height - 40.0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark Pan gesture recognizer (Private)

- (void)__panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled) {
        return;
    }
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self __updateContentViewShadow];
        
        self.originalPoint = CGPointMake(self.contentViewContainer.center.x - CGRectGetWidth(self.contentViewContainer.bounds) / 2.0,
                                         self.contentViewContainer.center.y - CGRectGetHeight(self.contentViewContainer.bounds) / 2.0);
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.backgroundImageView.frame = self.view.bounds;
        }
        self.menuViewContainer.frame = self.view.bounds;
        [self __addContentButton];
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = 0;
        if (self.visible) {
            delta = self.originalPoint.y != 0 ? (point.y + self.originalPoint.y) / self.originalPoint.y : 0;
        } else {
            delta = point.y / self.view.frame.size.width;
        }
        delta = MIN(fabs(delta), 1.6);
        
        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;
        
        CGFloat backgroundViewScale = 1.7f - (0.7f * delta);
        CGFloat menuViewScale = 1.5f - (0.5f * delta);

        if (!self.bouncesHorizontally) {
            contentViewScale = MAX(contentViewScale, self.contentViewScaleValue);
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }
        
        self.menuViewContainer.alpha = delta;
        
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(backgroundViewScale, backgroundViewScale);
        }
        
        if (self.scaleMenuView) {
            self.menuViewContainer.transform = CGAffineTransformMakeScale(menuViewScale, menuViewScale);
        }
        
        if (self.scaleBackgroundImageView) {
            if (backgroundViewScale < 1) {
                self.backgroundImageView.transform = CGAffineTransformIdentity;
            }
        }
        
       if (!self.bouncesHorizontally && self.visible) {
           if (self.contentViewContainer.frame.origin.y > self.contentViewContainer.frame.size.width / 2.0)
               point.y = MIN(0.0, point.y);
           
            if (self.contentViewContainer.frame.origin.y < -(self.contentViewContainer.frame.size.width / 2.0))
                point.y = MAX(0.0, point.y);
        }
        
        // Limit size
        //
        if (point.y < 0) {
            point.y = MAX(point.y, -[UIScreen mainScreen].bounds.size.height);
        } else {
            point.y = MIN(point.y, [UIScreen mainScreen].bounds.size.height);
        }
        [recognizer setTranslation:point inView:self.view];
        
        if (!self.didNotifyDelegate) {
            if (point.y > 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.topMenuViewController];
                }
            }
            if (point.y < 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.bottomMenuViewController];
                }
            }
            self.didNotifyDelegate = YES;
        }
        
        if (contentViewScale > 1) {
            CGFloat oppositeScale = (1 - (contentViewScale - 1));
            self.contentViewContainer.transform = CGAffineTransformMakeScale(oppositeScale, oppositeScale);
            self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, 0,point.y);
        } else {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(contentViewScale, contentViewScale);
            self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, 0,point.y);
        }
        
        self.topMenuViewController.view.hidden = self.contentViewContainer.frame.origin.y < 0;
        self.bottomMenuViewController.view.hidden = self.contentViewContainer.frame.origin.y > 0;
        
        if (!self.topMenuViewController && self.contentViewContainer.frame.origin.y > 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.topMenuVisible = NO;
        } else  if (!self.bottomMenuViewController && self.contentViewContainer.frame.origin.y < 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.bottomMenuVisible = NO;
        }
        
        [self __statusBarNeedsAppearanceUpdate];
    }
    
   if (recognizer.state == UIGestureRecognizerStateEnded)
   {
        self.didNotifyDelegate = NO;
        if (self.panMinimumOpenThreshold > 0 && (
            (self.contentViewContainer.frame.origin.y < 0 && self.contentViewContainer.frame.origin.y > -((NSInteger)self.panMinimumOpenThreshold)) ||
            (self.contentViewContainer.frame.origin.y > 0 && self.contentViewContainer.frame.origin.y < self.panMinimumOpenThreshold))
            )
        {
            [self hideMenuViewController];
        }
        else if (self.contentViewContainer.frame.origin.y == 0)
        {
            [self __hideMenuViewControllerAnimated:NO];
        }
        else
        {
            if ([recognizer velocityInView:self.view].y > 0)
            {
                if (self.contentViewContainer.frame.origin.y < 0)
                {
                    [self hideMenuViewController];
                }
                else
                {
                    if (self.topMenuViewController)
                    {
                        [self __showTopMenuViewController];
                    }
                }
            }
            else
            {
                if (self.contentViewContainer.frame.origin.y < 20)
                {
                    if (self.bottomMenuViewController)
                    {
                        [self __showBottomMenuViewController];
                    }
                }
                else
                {
                    [self hideMenuViewController];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    [self __hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self __updateContentViewShadow];
    
    if (self.visible) {
        [self __addContentViewControllerMotionEffects];
    }
}

- (void)setTopMenuViewController:(UIViewController *)topMenuViewController
{
    if (!_topMenuViewController) {
        _topMenuViewController = topMenuViewController;
        return;
    }
    [self __hideViewController:_topMenuViewController];
    _topMenuViewController = topMenuViewController;
   
    [self addChildViewController:self.topMenuViewController];
    self.topMenuViewController.view.frame = self.view.bounds;
    self.topMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.topMenuViewController.view];
    [self.topMenuViewController didMoveToParentViewController:self];
    
    [self __addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

- (void)setBottomMenuViewController:(UIViewController *)bottomMenuViewController
{
    if (!_bottomMenuViewController) {
        _bottomMenuViewController = bottomMenuViewController;
        return;
    }
    [self __hideViewController:_bottomMenuViewController];
    _bottomMenuViewController = bottomMenuViewController;
    
    [self addChildViewController:self.bottomMenuViewController];
    self.bottomMenuViewController.view.frame = self.view.bounds;
    self.bottomMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.bottomMenuViewController.view];
    [self.bottomMenuViewController didMoveToParentViewController:self];
    
    [self __addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

#pragma mark -
#pragma mark View Controller Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.visible) {
        self.menuViewContainer.bounds = self.view.bounds;
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        self.contentViewContainer.frame = self.view.bounds;
        
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        
        CGPoint center;
        if (self.topMenuVisible) {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
        } else {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
        }
        
        self.contentViewContainer.center = center;
    }
    
    [self __updateContentViewShadow];
}

#pragma mark -
#pragma mark Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    IF_IOS7_OR_GREATER(
       statusBarStyle = self.visible ? self.menuPreferredStatusBarStyle : self.contentViewController.preferredStatusBarStyle;
       if (self.contentViewContainer.frame.origin.y > 10) {
           statusBarStyle = self.menuPreferredStatusBarStyle;
       } else {
           statusBarStyle = self.contentViewController.preferredStatusBarStyle;
       }
    );
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    IF_IOS7_OR_GREATER(
        statusBarHidden = self.visible ? self.menuPrefersStatusBarHidden : self.contentViewController.prefersStatusBarHidden;
        if (self.contentViewContainer.frame.origin.y > 10) {
            statusBarHidden = self.menuPrefersStatusBarHidden;
        } else {
            statusBarHidden = self.contentViewController.prefersStatusBarHidden;
        }
    );
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    IF_IOS7_OR_GREATER(
        statusBarAnimation = self.visible ? self.topMenuViewController.preferredStatusBarUpdateAnimation : self.contentViewController.preferredStatusBarUpdateAnimation;
        if (self.contentViewContainer.frame.origin.y > 10) {
            statusBarAnimation = self.topMenuViewController.preferredStatusBarUpdateAnimation;
        } else {
            statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
        }
    );
    return statusBarAnimation;
}

@end
