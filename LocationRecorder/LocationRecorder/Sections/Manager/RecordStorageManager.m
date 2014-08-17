//
//  RecordStorageManager.m
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordStorageManager.h"
#import "GVUserDefaults+AppConfig.h"


#define kCurrRecordListKey                  @"CurrRecordList"


@interface RecordStorageManager ()

@end

@implementation RecordStorageManager

+ (RecordStorageManager *)sharedInstance
{
    static RecordStorageManager *s_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self.class alloc] init];
    });
    
    return s_manager;
}


- (void)saveRecord:(RecordModel *)recordModel
{
    NSMutableDictionary *recordListDic = [[NSMutableDictionary alloc] initWithDictionary:AppConfigInstance.locationRecordDic];
    NSData *recordArrayData = recordListDic[kCurrRecordListKey];

    NSMutableArray *recordArray;
    if (recordArrayData)
    {
        recordArray = [[NSMutableArray alloc] initWithArray:((NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:recordArrayData])];
    }
    else
    {
        recordArray = [[NSMutableArray alloc] init];
    }
    
    [recordArray addObject:recordModel];
    recordArrayData = [NSKeyedArchiver archivedDataWithRootObject:recordArray];
    recordListDic[kCurrRecordListKey] = recordArrayData;
    
    AppConfigInstance.locationRecordDic = recordListDic;
    [AppConfigInstance saveAll];
}

- (void)resetRecords:(NSArray *)newRecordArray
{
    NSMutableDictionary *recordListDic = [[NSMutableDictionary alloc] initWithDictionary:AppConfigInstance.locationRecordDic];
    
    if (!newRecordArray)
    {
        newRecordArray = [[NSArray alloc] init];
    }else{}
    NSData *recordArrayData = [NSKeyedArchiver archivedDataWithRootObject:newRecordArray];
    recordListDic[kCurrRecordListKey] = recordArrayData;
    
    AppConfigInstance.locationRecordDic = recordListDic;
    [AppConfigInstance saveAll];
}

- (NSArray *)allRecords
{
    NSMutableArray *recordArray;
    NSMutableDictionary *recordListDic = [[NSMutableDictionary alloc] initWithDictionary:AppConfigInstance.locationRecordDic];
    NSData *recordArrayData = recordListDic[kCurrRecordListKey];
    
    if (recordArrayData)
    {
        recordArray = [[NSMutableArray alloc] initWithArray:((NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:recordArrayData])];
    }
    else
    {
        recordArray = [[NSMutableArray alloc] init];
    }
    
    return recordArray;
}

- (void)removeAllRecords
{
    [self resetRecords:[[NSArray alloc] init]];
}
















@end
