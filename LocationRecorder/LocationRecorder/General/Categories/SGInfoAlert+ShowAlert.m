//
//  SGInfoAlert+ShowAlert.m
//  Eventor
//
//  Created by jimple on 14-6-11.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "SGInfoAlert+ShowAlert.h"

@implementation SGInfoAlert (ShowAlert)


+ (void)showAlert:(NSString *)strMsg inView:(UIView *)view
{
    [[self class] showAlert:strMsg duration:0.5f inView:view];
}

+ (void)showAlert:(NSString *)strMsg duration:(CGFloat)fDuration inView:(UIView *)view
{
    [SGInfoAlert showInfo:strMsg bgColor:[UIColor blackColor].CGColor inView:view vertical:0.5f duration:fDuration];
}


@end
