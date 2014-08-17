//
//  PosPinAnnotation.h
//  MetroCateCoupon
//
//  Created by jimple on 12-5-23.
//  Copyright (c) 2012年 JimpleChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PosPinAnnotation : NSObject <MKAnnotation>
{
@private
    UIImage *_image;
    CLLocationCoordinate2D  _coordinate;
    NSString        *_title;  
    NSString        *_subtitle;
    NSInteger _iUserInfoIndex;
}

@property (nonatomic, readonly)  CLLocationCoordinate2D  coordinate;  
@property (nonatomic, copy) NSString *title;  
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) UIImage *m_img;
@property (nonatomic, assign) NSInteger m_iUserInfoIndex;

- (id) initWithCoordinate:(CLLocationCoordinate2D)objCoord;


@end
