//
//  RecordStorageManager.h
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RecordStorageManagerObj       [RecordStorageManager sharedInstance]

@class RecordModel;
@interface RecordStorageManager : NSObject

+ (RecordStorageManager *)sharedInstance;


- (void)saveRecord:(RecordModel *)recordModel;
- (void)resetRecords:(NSArray *)newRecordArray;
- (NSArray *)allRecords;

//移除所有点位记录
- (void)removeAllRecords;

//利用所有点位信息记录生成KML文件, 返回文件名
- (NSString *)createKMLfileFromRecords;


@end
