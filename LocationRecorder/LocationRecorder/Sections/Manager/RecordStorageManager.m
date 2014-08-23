//
//  RecordStorageManager.m
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordStorageManager.h"
#import "GVUserDefaults+AppConfig.h"
#import "RecordModel.h"
#import "KML.h"

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



//利用所有点位信息记录生成KML文件
- (NSString *)createKMLfileFromRecords
{
    NSMutableArray *recordPtns = [[NSMutableArray alloc] initWithArray:[self allRecords]];
    if (recordPtns)
    {
        KMLRoot *root = [KMLRoot new];
        
        KMLDocument *doc = [KMLDocument new];
        doc.name = @"点位信息列表";
        root.feature = doc;
        
        //添加点信息
        for (RecordModel *recordModel in recordPtns)
        {
            KMLPlacemark *placemark = [self addSinglePlacemark:recordModel];
            [doc addFeature:placemark];
        }
        
        //添加线信息
        KMLPlacemark *line = [self addLines:recordPtns];
        [doc addFeature:line];
        
        //写入文件
        NSString *kmlString = root.kml;
        NSError *error;
        NSString *filePath = [self kmlFilePath];
        if (![kmlString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
        {
            if (error)
            {
                NSLog(@"error, %@", error);
            }
            return nil;
        }
        
        //NSLog(@" %@", filePath);
        return filePath;
    }
    else{return nil;}
}

//添加单点坐标信息
- (KMLPlacemark *)addSinglePlacemark:(RecordModel *)recordModel
{
    KMLPlacemark *placemark = [KMLPlacemark new];
    placemark.name = recordModel.title;                //点名
    placemark.descriptionValue = recordModel.address;  //地址
    
    KMLPoint *point = [KMLPoint new];
    placemark.geometry = point;
    
    KMLCoordinate *coordinate = [KMLCoordinate new];
    coordinate.latitude = recordModel.location.coordinate.latitude;
    coordinate.longitude = recordModel.location.coordinate.longitude;
    point.coordinate = coordinate;
    
    return placemark;
}

//添加线信息
- (KMLPlacemark *)addLines:(NSMutableArray *) recordPtns
{
    KMLPlacemark *placemark = [KMLPlacemark new];
    placemark.name = @"路线信息";
    
    __block KMLLineString *lineString = [KMLLineString new];
    placemark.geometry = lineString;
    
    [recordPtns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         RecordModel *trackPoint = (RecordModel *)obj;
         KMLCoordinate *coordinate = [KMLCoordinate new];
         coordinate.latitude = trackPoint.location.coordinate.latitude;
         coordinate.longitude = trackPoint.location.coordinate.longitude;
         [lineString addCoordinate:coordinate];
     }];
    
    KMLStyle *style = [KMLStyle new];
    [placemark addStyleSelector:style];
    
    KMLLineStyle *lineStyle = [KMLLineStyle new];
    style.lineStyle = lineStyle;
    lineStyle.width = 5;
    lineStyle.UIColor = [UIColor blueColor];
    
    return placemark;
}

//KML文件名
- (NSString *)kmlFilePath
{
    //用日期来命名
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeStyle = NSDateFormatterFullStyle;
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [NSString stringWithFormat:@"log_%@.kml", dateString];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}









@end
