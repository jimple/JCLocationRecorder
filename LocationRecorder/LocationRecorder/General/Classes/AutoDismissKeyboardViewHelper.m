//
//  AutoDismissKeyboardViewHelper.m
//  Eventor
//
//  Created by jimple on 14-6-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "AutoDismissKeyboardViewHelper.h"

@interface AutoDismissKeyboardViewHelper ()

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation AutoDismissKeyboardViewHelper


- (id)initWithView:(UIView *)view
{
    APP_ASSERT(view);
    self = [super init];
    if (self)
    {
        _parentView = view;
        _coverView = [[UIView alloc] initWithFrame:view.bounds];
        _coverView.backgroundColor = RGBA(0.0, 0.0f, 0.0f, 0.001f);
        [self setUpForDismissKeyboard];
    }else{}
    return self;
}

- (void)dealloc
{
    if (_coverView)
    {
        [_coverView removeFromSuperview];
    }else{}
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpForDismissKeyboard
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [_coverView removeFromSuperview];
                    _coverView.frame = _parentView.bounds;
                    [_parentView addSubview:_coverView];
                    [_parentView bringSubviewToFront:_coverView];
                    [_coverView addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [_coverView removeFromSuperview];
                    [_coverView removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    //此method会将self.view里所有的subview的first responder都resign掉
    [_parentView endEditing:YES];
}













@end
