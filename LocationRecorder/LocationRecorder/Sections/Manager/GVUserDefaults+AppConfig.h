//
//  GVUserDefaults+AppConfig.h
//  Vaccin
//
//  Created by jimple on 14/7/29.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "GVUserDefaults.h"

#define AppConfigInstance                   [GVUserDefaults standardUserDefaults]

@interface GVUserDefaults (AppConfig)

@property (nonatomic, weak) NSDictionary *appVersion2LaunchTimesDic;


- (void)saveAll;


@end
