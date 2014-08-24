//
//  RecordDetailViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/13.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RecordModel.h"
#import "QBImagePickerController.h"
#import "RecordStorageManager.h"
#import "SGInfoAlert+ShowAlert.h"
#import "RecordMediaViewController.h"

@interface RecordDetailViewController ()
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    QBImagePickerControllerDelegate
>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *horizontalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *verticalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *datetimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *showImgLabel;


@end

@implementation RecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"位置详情";
    
    APP_ASSERT(_recordArray);
    
    RecordModel *record = _recordArray[_recordIndex];
    
    self.titleLabel.text = record.title;
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.6f", record.location.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.6f", record.location.coordinate.longitude];
    self.horizontalAccuracyLabel.text = [NSString stringWithFormat:@"±%.2f m", record.location.horizontalAccuracy];
    self.verticalAccuracyLabel.text = [NSString stringWithFormat:@"±%.2f m", record.location.verticalAccuracy];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%.2f m", record.location.altitude];
    self.addressLabel.text = record.address;
    self.datetimeLabel.text = [UtilityFunc getStringFromDate:[NSDate dateWithTimeIntervalSince1970:record.recordTime.doubleValue] byFormat:kDatetimeFormat] ;
    
    [self updateShowImgLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return 5;
        }
            break;
        case 1:
        {
            return 2;
        }
        default:
        {
            return 0;
        }
            break;
    }
    return 0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueRecordMedia"])
    {
        @weakify(self);
        RecordModel *record = _recordArray[_recordIndex];
        [((RecordMediaViewController *)(segue.destinationViewController)) setImgFilePathArray:record.imgFileNameArray];
        ((RecordMediaViewController *)(segue.destinationViewController)).resetImgArrHandler = ^(NSArray *newImgArr)
        {
            @strongify(self);
            [self resetImgArray:newImgArr];
        };
    }else{}
}

#pragma mark - Action
- (IBAction)cameraBtn:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{}
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    
    [self presentViewController:picker animated:YES completion:^(){}];
}

- (IBAction)albumBtn:(id)sender
{
    if ([QBImagePickerController isAccessible])
    {
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = NO;         // 只能选一张相片
        imagePickerController.groupTypes = @[
                                             @(ALAssetsGroupSavedPhotos),
                                             @(ALAssetsGroupPhotoStream),
                                             @(ALAssetsGroupAlbum)
                                             ];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"\n\n\n\n没有读取相册的权限\n\n\n");
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
 
    if ((indexPath.section == 1) && (indexPath.row == 1))
    {// 显示图片列表
        [self performSegueWithIdentifier:@"SegueRecordMedia" sender:nil];
    }else{}
}

#pragma mark - ImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^(){}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image)
    {
        // 保存一份到相册
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                  orientation:(ALAssetOrientation)[image imageOrientation]
                              completionBlock:nil];
        
        [SGInfoAlert showAlert:@"正在处理图片" duration:0.2f inView:self.view];
        [self performSelector:@selector(saveImg:) withObject:image afterDelay:0.1f];
    }else{}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark - QBImagePickerControllerDelegate 
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    [self dismissImagePickerController];
    
    [self performSelector:@selector(saveImg:) withObject:tempImg afterDelay:0.1f];
}
//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
//{
//    
//}
//
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

#pragma mark -
- (void)saveImg:(UIImage *)img
{
    if (img)
    {
        NSString *fileName = [RecordStorageManager saveImgToFile:img];
        if (StringNotEmpty(fileName))
        {
            RecordModel *record = _recordArray[_recordIndex];
            NSMutableArray *fileNameArr = [[NSMutableArray alloc] initWithArray:record.imgFileNameArray];
            [fileNameArr addObject:fileName];
            record.imgFileNameArray = fileNameArr;
            
            _recordArray[_recordIndex] = record;
            [RecordStorageManagerObj resetRecords:_recordArray];
            [self updateShowImgLabel];
            [SGInfoAlert showAlert:@"保存成功" duration:0.3f inView:self.view];
        }else{APP_ASSERT_STOP}
    }else{APP_ASSERT_STOP}
}

- (void)updateShowImgLabel
{
    RecordModel *record = _recordArray[_recordIndex];
    self.showImgLabel.text = [NSString stringWithFormat:@"查看相片 - 共 %d 张", (record.imgFileNameArray ? record.imgFileNameArray.count : 0)];
}

- (void)resetImgArray:(NSArray *)imgPathArray
{
    RecordModel *record = _recordArray[_recordIndex];
    NSMutableArray *fileNameArr = [[NSMutableArray alloc] initWithArray:imgPathArray];
    record.imgFileNameArray = fileNameArr;
    _recordArray[_recordIndex] = record;
    [RecordStorageManagerObj resetRecords:_recordArray];
    [self updateShowImgLabel];
}

















































@end
