//
//  GVUserDefaults+AppConfig.m
//  Vaccin
//
//  Created by jimple on 14/7/29.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "GVUserDefaults+AppConfig.h"

@implementation GVUserDefaults (AppConfig)
@dynamic locationRecordDic;

//- (NSString *)transformKey:(NSString *)key
//{
//    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
//    return [NSString stringWithFormat:@"NSUserDefault%@", key];
//}

- (NSDictionary *)setupDefaults
{
    return @{
             @"locationRecordDic": @{},
             };
}

- (void)saveAll
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
