//
//  fbpageViewController.h
//  fb
//
//  Created by Arnas on 21/03/14.
//  Copyright (c) 2014 Arnas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fbpageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSMutableArray *backgroundImages;
-(void) nextImage;
-(void) imageTapped;
@end
