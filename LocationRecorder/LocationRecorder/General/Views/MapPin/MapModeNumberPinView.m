//
//  MapModeNumberPinView.m
//  BitesOfCities
//
//  Created by jimple on 13-11-13.
//  Copyright (c) 2013年 JimpleChen. All rights reserved.
//

#import "MapModeNumberPinView.h"

@interface MapModeNumberPinView ()

@property (nonatomic, readonly) NSInteger m_iIndex;
@property (nonatomic, readonly) UILabel *m_labelNumber;

@end

@implementation MapModeNumberPinView
@synthesize m_iIndex = _iIndex;
@synthesize m_labelNumber = _labelNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _iIndex = -1;
        
        
        _labelNumber = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 6.0f, 11.0f, 11.0f)];
        _labelNumber.backgroundColor = [UIColor clearColor];
        _labelNumber.textAlignment = NSTextAlignmentCenter;
        _labelNumber.textColor = [UIColor blackColor];
        _labelNumber.font = [UIFont systemFontOfSize:11.0f];
        [UtilityFunc label:_labelNumber setMiniFontSize:6.0f forNumberOfLines:1];
        _labelNumber.text = @"";
        
        [self addSubview:_labelNumber];
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

- (void)showIndex:(NSInteger)iIndex
{
    _iIndex = iIndex;
    _labelNumber.text = (_iIndex > 0) ? [NSString stringWithFormat:@"%d", iIndex] : @"";
}



@end
