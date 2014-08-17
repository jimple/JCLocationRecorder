//
//  RecordStorageManager.h
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RecordStorageManagerObj                 [RecordStorageManager sharedInstance]

@class RecordModel;
@interface RecordStorageManager : NSObject


+ (RecordStorageManager *)sharedInstance;


- (void)saveRecord:(RecordModel *)recordModel;
- (void)resetRecords:(NSArray *)newRecordArray;
- (NSArray *)allRecords;
- (void)removeAllRecords;


@end
