//
//  RecordModel.m
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordModel.h"

@implementation RecordModel


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
