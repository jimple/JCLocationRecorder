//
//  PosPinAnnotation.m
//  MetroCateCoupon
//
//  Created by jimple on 12-5-23.
//  Copyright (c) 2012年 JimpleChen. All rights reserved.
//

#import "PosPinAnnotation.h"

@implementation PosPinAnnotation
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize m_img = _image;
@synthesize m_iUserInfoIndex = _iUserInfoIndex;

- (id) initWithCoordinate:(CLLocationCoordinate2D)objCoord  
{  
    if ([super  init])  
    {  
        _coordinate = objCoord;
        _iUserInfoIndex = -1;
    }    
    return  self;  
}  



@end
