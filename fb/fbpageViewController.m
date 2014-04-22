//
//  fbpageViewController.m
//  fb
//
//  Created by Arnas on 21/03/14.
//  Copyright (c) 2014 Arnas. All rights reserved.
//

#import "fbpageViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "StoryView.h"
#import "AFNetworking.h"
#import "CRMotionView.h"

@interface fbpageViewController ()<UIScrollViewDelegate>

@end
static int SCROLL_HEIGHT_MINIMIZED = 225;
static char *pageID = "202499019787537";
static float PHOTO_REFRESH_TIME = 10.0f;
@implementation fbpageViewController
{
    BOOL open;
    CGFloat lastOpen;
    int downloadCount;
    CRMotionView *motionView;
    BOOL imageLock;
    NSString *fbDataString;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _scrollView.scrollEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
        open = NO;
        downloadCount = 0;
    }
    return self;
}

-(void) getFbPhotos
{
    if(fbDataString == nil)
        return;
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:fbDataString,pageID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if ([result isKindOfClass:[NSArray class]]) {
                                  result = [result objectAtIndex:0];
                              }
                              fbDataString = [((NSString*)[[result objectForKey:@"paging"] objectForKey:@"next"]) substringFromIndex:26];
                              NSArray *data = [result objectForKey:@"data"];
                              for( FBGraphObject *single in data )
                              {
                                  [self.backgroundImages addObject:[[[single objectForKey:@"images"] objectAtIndex:0] objectForKey:@"source"]];
                              }
                              [self downloadBackgroundImages];
                          }];
}
-(void) nextImage
{
    if(imageLock == NO)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        imageLock = YES;
        [self downloadBackgroundImages];
    }
}
-(void) downloadBackgroundImages
{
    if (self.backgroundImages == nil || [self.backgroundImages count] == 0) {
        return;
    }
    if(downloadCount == (int)([self.backgroundImages count]*2/3))
    {
        [self getFbPhotos];
    }
    NSURLRequest *req = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[self.backgroundImages objectAtIndex:downloadCount++]]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [motionView setImage:responseObject];
        imageLock = NO;
        [self performSelector:@selector(nextImage)
                   withObject:nil
                   afterDelay:PHOTO_REFRESH_TIME];
        if (downloadCount == [self.backgroundImages count]) {
            downloadCount = 0;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOperation start];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    motionView = [[CRMotionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) parent:self];
    [self.view addSubview:motionView];
    [self.view bringSubviewToFront:self.scrollView];
    fbDataString = @"/%s/photos";
    imageLock = YES;
    self.backgroundImages = [[NSMutableArray alloc]init];
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = self.view.frame.size.height - SCROLL_HEIGHT_MINIMIZED;
    self.scrollView.frame = scrollFrame;
    CGFloat lastX;
    for (NSInteger i = 0; i < 5; i++) {
        lastX = self.view.frame.size.width/2.5*i;
        lastX += 2*i;
        StoryView *story = [[StoryView alloc]initWithFrame:CGRectMake(lastX, 0, self.view.frame.size.width/2.5, SCROLL_HEIGHT_MINIMIZED)];
        [story setTag:i];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [story addGestureRecognizer:tapGestureRecognizer];
        [_scrollView addSubview:story];
        int contX = ((self.view.frame.size.width/2.5)+2)*(i+1);
        _scrollView.contentSize = CGSizeMake(contX, SCROLL_HEIGHT_MINIMIZED);
    }
    [self getFbPhotos];
}
- (void)handleTapFrom:(UITapGestureRecognizer *)sender
{
    int scrollHeight,viewWidth;
    if(open == NO)
        lastOpen = self.scrollView.contentOffset.x; //save the offset when the minimized view is tapped
    CGRect frame = _scrollView.frame;
    if(open == NO)
    {
        scrollHeight = self.view.frame.size.height;
        viewWidth = self.view.frame.size.width;
        self.scrollView.pagingEnabled = YES;
        frame.origin.y = 0;
    }
    else
    {
        scrollHeight = SCROLL_HEIGHT_MINIMIZED;
        viewWidth = (self.view.frame.size.width/2.5);
        self.scrollView.pagingEnabled = NO;
        frame.origin.y = self.view.frame.size.height - SCROLL_HEIGHT_MINIMIZED;
    }
    NSInteger element = sender.view.tag;
    frame.size.height = scrollHeight;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGSize lastsize;
    self.scrollView.frame = frame;
    for( UIView *view in self.scrollView.subviews)
    {
        if([view isKindOfClass:[StoryView class]])
        {
            CGRect subframe = view.frame;
            subframe.origin.x = (viewWidth * view.tag)+(open?2:0)*view.tag;
            subframe.size.width = viewWidth;
            subframe.size.height = scrollHeight;
            view.frame = subframe;
            lastsize = CGSizeMake(subframe.origin.x+subframe.size.width, scrollHeight);
        }
    }
    
    [UIView commitAnimations];
    self.scrollView.contentSize = lastsize;
    if(open == YES)
        [self.scrollView scrollRectToVisible:CGRectMake(lastOpen, 0, viewWidth, scrollHeight) animated:NO];
    else
        [self.scrollView scrollRectToVisible:CGRectMake(viewWidth*element, 0, viewWidth, scrollHeight) animated:NO];
    open = open ? NO : YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
