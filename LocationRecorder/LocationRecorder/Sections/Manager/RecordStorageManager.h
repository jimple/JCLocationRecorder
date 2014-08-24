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
+ (NSString *)imgFolderPath;

// 把图片保存到图片目录下，返回文件名称
+ (NSString *)saveImgToFile:(UIImage *)image;

// 删除整个图片目录
+ (BOOL)clearImgFolder;

// 缩略图文件名
+ (NSString *)thumbFileNameByFileName:(NSString *)fileName;



#pragma mark -

- (void)saveRecord:(RecordModel *)recordModel;
- (void)resetRecords:(NSArray *)newRecordArray;
- (NSArray *)allRecords;

// 删除数据同时删除图片文件目录
- (void)removeAllRecords;

//利用所有点位信息记录生成KML文件, 返回文件名
- (NSString *)createKMLfileFromRecords;

//删除整个KML文件夹
-(BOOL)clearKmlFolder;




@end
