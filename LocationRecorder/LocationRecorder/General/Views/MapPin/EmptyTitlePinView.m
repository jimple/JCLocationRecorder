//
//  EmptyTitlePinView.m
//  BitesOfCities
//
//  Created by jimple on 13-11-11.
//  Copyright (c) 2013年 JimpleChen. All rights reserved.
//

#import "EmptyTitlePinView.h"

@implementation EmptyTitlePinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}



@end
