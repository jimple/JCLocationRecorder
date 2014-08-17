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
<NSCoding>

@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSNumber *recordTime; // timeIntervalSince1970
@property (nonatomic, copy) NSString *address;

- (CLLocationCoordinate2D)googleCoordinateFromLocation;

@end
