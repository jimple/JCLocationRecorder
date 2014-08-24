//
//  RecordStorageManager.m
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordStorageManager.h"
#import "GVUserDefaults+AppConfig.h"
#import "KML.h"
#import "RecordModel.h"

#define kCurrRecordListKey                  @"CurrRecordList"
#define kImgFolderName                      @"PhotosFolder"


#define kJPEGFileQuality                    0.8f        // ! jpg 质量参数设置，参数越小图片压缩越大    0.0 - 1.0


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

+ (NSString *)imgFolderPath
{
    static NSString *path;
    if (!StringNotEmpty(path))
    {
        path = [UtilityFunc getFilePathFromDocument:kImgFolderName];
    }else{}
    
    return path;
}

// 把图片保存到图片目录下，返回文件名称
+ (NSString *)saveImgToFile:(UIImage *)image
{
    NSString *fileName = @"";
    if (image)
    {
        if (![UtilityFunc isFileExist:[self.class imgFolderPath]])
        {
            [UtilityFunc createFolder:[self.class imgFolderPath]];
        }else{}
        
        fileName = [NSString stringWithFormat:@"%@.jpg", [UtilityFunc getStringFromDate:[NSDate date] byFormat:@"yyyy-MM-dd_HH-mm-ss"]];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self.class imgFolderPath], fileName];
        [UIImageJPEGRepresentation(image, kJPEGFileQuality) writeToFile:filePath atomically:YES];
//      [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        
        // 同时保存一张低质量的图片用于在列表中显示
        CGFloat scale = 120.0f / image.size.width;
        CGSize thumbSize = CGSizeMake(120.0f, scale * image.size.height);
        UIImage *thumbImg = [UtilityFunc reSizeImage:image toSize:thumbSize];
        NSString *thumbFilePath = [NSString stringWithFormat:@"%@/%@", [self.class imgFolderPath], [self.class thumbFileNameByFileName:fileName]];
        [UIImageJPEGRepresentation(thumbImg, 1.0f) writeToFile:thumbFilePath atomically:YES];
    }else{APP_ASSERT_STOP}
    return fileName;
}

+ (NSString *)thumbFileNameByFileName:(NSString *)fileName
{
    return [NSString stringWithFormat:@"thumb_%@", fileName];
}

// 删除整个图片目录
+ (BOOL)clearImgFolder
{
    BOOL succ = NO;
    NSString *folderPath = [self.class imgFolderPath];
    if ([UtilityFunc isFolderExist:folderPath])
    {
        succ = [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
    }
    else
    {
        succ = YES;
    }
    return succ;
}

#pragma mark -
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

// 删除数据同时删除图片文件目录
- (void)removeAllRecords
{
    [self resetRecords:[[NSArray alloc] init]];
    [self.class clearImgFolder];
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




// 遍历记录数组，读取数组元素的内容。
/*
 读取全部数据：
 1、 使用 - (NSArray *)allRecords; 获得全部记录的数组，每个数组元素是一个 RecordModel 对象。
 2、 用for遍历数组可将每个model读取
 */
/*
- (void)temp
{
    NSArray *recordArray = [RecordStorageManagerObj allRecords];
    
    
    ///////////////////////////////////////////////////////
    // 假如想对数组中的时间进行排序，可如下做排序。排序后的数组为  sortArray
    // 如果想对其它元素进行排序，就取出其它元素做比较，返回 NSComparisonResult 即可。
    NSArray *sortArray = [recordArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RecordModel *model1 = (RecordModel *)obj1;
        RecordModel *model2 = (RecordModel *)obj2;
        NSComparisonResult result = [model1.recordTime compare:model2.recordTime];
        
        return result == NSOrderedDescending; // 升序
//        return result == NSOrderedAscending;  // 降序
    }];
    ///////////////////////////////////////////////////////
    
    for (RecordModel *model in recordArray)
    {
        // title字符串
        NSString *title = model.title;
        NSTimeInterval recordTime = [model.recordTime doubleValue]; // 时间是一个1970至今的秒数
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:recordTime]; // 获得时间类型的时间
        NSString *dateStr = [UtilityFunc getStringFromDate:date byFormat:@"yyyy-MM-dd HH:ss:mm"];   // 时间转成字符串输出
        
        // 保存图片文件名的数组，仅保存文件名，文件目录路径通过  imgFolderPath  函数获得
        for (NSString *imgFileName in model.imgFileNameArray)
        {
            // 拼凑出文件路径
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", [RecordStorageManager imgFolderPath], imgFileName];
            
            // 保存图片时同时保存了一个小图方便在列表中显示。通过如下方法获得缩略图路径
            NSString *thumbFilePath = [NSString stringWithFormat:@"%@/%@", [RecordStorageManager imgFolderPath], [RecordStorageManager thumbFileNameByFileName:imgFileName]];
        }
    }
}

*/











@end
