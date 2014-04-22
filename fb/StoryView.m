//
//  StoryView.m
//  fb
//
//  Created by Arnas on 03/04/14.
//  Copyright (c) 2014 Arnas. All rights reserved.
//

#import "StoryView.h"

@import QuartzCore;

@implementation StoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.layer setBorderWidth:0.5];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = .5f;
        CGRect textFrame = frame;
        textFrame.origin.x = 5;
        textFrame.origin.y = 5;
        textFrame.size.width -= 10;
        textFrame.size.height -= 10;
        self.textLabel = [[UILabel alloc]initWithFrame:textFrame];
        self.textLabel.text = @"Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label Label";
        self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 0;
        [self addSubview:self.textLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
