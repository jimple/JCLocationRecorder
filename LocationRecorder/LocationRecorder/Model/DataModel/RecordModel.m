//
//  RecordModel.m
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordModel.h"
#import "TransformCorrdinate.h"

@implementation RecordModel

- (CLLocationCoordinate2D)googleCoordinateFromLocation
{
    APP_ASSERT(self.location);
    CLLocationCoordinate2D coor;
    coor.latitude = 0.0f;
    coor.longitude = 0.0f;
    if (self.location)
    {
        coor = [TransformCorrdinate GPSLocToGoogleLoc:self.location.coordinate];
    }else{}
    return coor;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.location = [coder decodeObjectForKey:@"location"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.recordTime = [coder decodeObjectForKey:@"recordTime"];
        self.address = [coder decodeObjectForKey:@"address"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.recordTime forKey:@"recordTime"];
    [coder encodeObject:self.address forKey:@"address"];
}

@end
