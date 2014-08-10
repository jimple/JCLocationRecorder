//
//  RecordModel.h
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RecordModel : NSObject

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *recordTime;
@property (nonatomic, strong) NSString *address;

@end
