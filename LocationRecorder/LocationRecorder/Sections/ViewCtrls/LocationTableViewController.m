//
//  LocationTableViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/10.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "LocationTableViewController.h"
#import "TSMessage.h"
#import "TransformCorrdinate.h"
#import <CoreLocation/CoreLocation.h>
#import "RecordModel.h"
#import "RecordStorageManager.h"
#import "SIAlertView.h"
#import "SGInfoAlert+ShowAlert.h"

@interface LocationTableViewController ()
<
    CLLocationManagerDelegate,
    UITextFieldDelegate
>

@property (nonatomic, weak) IBOutlet UITextField *nameTxtField;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *horizontalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *verticalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *datetimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *refreshingTipsLabel;
@property (nonatomic, weak) IBOutlet UIButton *locationSwitchBtn;
@property (nonatomic, weak) IBOutlet UIButton *saveBtn;

@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) RecordModel *recordModel;
@property (nonatomic, strong) UIColor *defaultAddressTxtColor;
@property (nonatomic, copy) NSString *lastSavedRecordTitle;

@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"定位";
    
    _locationMgr = [[CLLocationManager alloc] init];
    _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    _locationMgr.delegate = self;
    _recordModel = [[RecordModel alloc] init];
    _lastSavedRecordTitle = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppEnterBackground:)
                                                 name:kNFAppEnterBackground
                                               object:nil];
    
    // UI
    self.nameTxtField.placeholder = @"请输入名称";
    [self.locationSwitchBtn setTitle:@"开始定位" forState:UIControlStateNormal];
    [self.locationSwitchBtn setTitle:@"停止定位" forState:UIControlStateSelected];
    [self.locationSwitchBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.refreshingTipsLabel.hidden = YES;
    [self setupButtonUI:self.locationSwitchBtn];
    [self setupButtonUI:self.saveBtn];
    
    self.nameTxtField.delegate = self;
    [self.nameTxtField addTarget:self action:@selector(keyboardPressDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    _defaultAddressTxtColor = self.addressLabel.textColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action
- (IBAction)refreshBtn:(id)sender
{
    [UtilityFunc viewRemoveShadow:self.locationSwitchBtn];
    [self switchLocationService];
}

- (IBAction)saveBtn:(id)sender
{
    if ([self checkRecordDataAndShowInvalidItemStatus])
    {
        if ([_lastSavedRecordTitle isEqualToString:_recordModel.title])
        {// 为避免误触碰保存按钮，所以如果刚刚保存了同名记录，则先提示后保存。
            NSString *tips = [NSString stringWithFormat:@"名称 “%@” 与上一次保存时同名，是否继续保存？", _lastSavedRecordTitle];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"提示" andMessage:tips];
            alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromTop;
            @weakify(self);
            [alertView addButtonWithTitle:@"取消"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            [alertView addButtonWithTitle:@"保存"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      @strongify(self);
                                      [self saveCurrRecord];
                                  }];
            [alertView show];
        }
        else
        {
            [self saveCurrRecord];
        }
    }
    else
    {
        [self showFailedMsgTitle:@"部分数据缺失" subTitle:@"请检查是否填写了<名称>，是否已经获取到位置信息。"];
    }
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    [self showLocationInfo:newLocation];
    
    _recordModel.location = newLocation;
    _recordModel.recordTime = @([[NSDate date] timeIntervalSince1970]);
    
    // 坐标取地址
    // gps坐标转谷歌坐标
    CLLocationCoordinate2D objGoogleLoc = [TransformCorrdinate GPSLocToGoogleLoc:newLocation.coordinate];
    CLLocation *locToGetGeo = [[CLLocation alloc] initWithLatitude:objGoogleLoc.latitude longitude:objGoogleLoc.longitude];
    _geocoder = [[CLGeocoder alloc] init];
    __weak typeof(self) weakSelf = self;
    [_geocoder reverseGeocodeLocation:locToGetGeo completionHandler:^(NSArray *arrPlaceMarks, NSError *err)
     {
         __strong typeof(self) strongSelf = weakSelf;
         if (arrPlaceMarks && (arrPlaceMarks.count > 0))
         {
             CLPlacemark *objPlace = [arrPlaceMarks objectAtIndex:0];

             NSString *city = [objPlace.addressDictionary objectForKey:@"City"];
             NSString *street = [objPlace.addressDictionary objectForKey:@"Street"];
             NSString *subLocality = [objPlace.addressDictionary objectForKey:@"SubLocality"];
             NSString *name = [objPlace.addressDictionary objectForKey:@"Name"];
             strongSelf.recordModel.address = [NSString stringWithFormat:@"%@ %@ %@ %@", city, subLocality, street, name];
             strongSelf.addressLabel.text = strongSelf.recordModel.address;
             strongSelf.addressLabel.textColor = _defaultAddressTxtColor;
         }
         else
         {
             // 地址获取失败
             strongSelf.recordModel.address = @"";
             strongSelf.addressLabel.text = @"获取地址失败";
             strongSelf.addressLabel.textColor = [UIColor redColor];
         }
     }];
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    [self showFailedMsgTitle:@"获取坐标失败。" subTitle:error.localizedDescription];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _recordModel.title = textField.text;
    
    if (StringNotEmpty(textField.text))
    {
        [UtilityFunc viewRemoveShadow:textField];
    }else{}
}

#pragma mark - Notifcation
- (void)handleAppEnterBackground:(NSNotification *)noti
{
    [self stopLocationService];
}

#pragma mark -
- (void)keyboardPressDone:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)isLocationServicesEnabled
{
    return ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied));
}

- (void)switchLocationService
{
    if ([self isLocationServicesEnabled])
    {
        if (self.locationSwitchBtn.selected)
        {
            [_locationMgr stopUpdatingLocation];
            self.refreshingTipsLabel.hidden = YES;
        }
        else
        {
            self.addressLabel.text = @"";
            
            [_locationMgr startUpdatingLocation];
            self.refreshingTipsLabel.hidden = NO;
        }
        self.locationSwitchBtn.selected = !self.locationSwitchBtn.selected;
    }
    else
    {
        [self showFailedMsgTitle:@"获取坐标失败。" subTitle:@"请在设置中开启应用的定位权限。"];
    }
}

- (void)stopLocationService
{
    if (self.locationSwitchBtn.selected)
    {
        [_locationMgr stopUpdatingLocation];
        self.refreshingTipsLabel.hidden = YES;
        self.locationSwitchBtn.selected = !self.locationSwitchBtn.selected;
    }else{}
}

- (void)showLocationInfo:(CLLocation *)location
{
    float altitude = location.altitude;
    float latitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    float hAccuracy = location.horizontalAccuracy;
    float vAccuracy = location.verticalAccuracy;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.6f", latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.6f", longitude];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%.2f m", altitude];
    self.horizontalAccuracyLabel.text = [NSString stringWithFormat:@"±%.2f m", hAccuracy];
    self.verticalAccuracyLabel.text = [NSString stringWithFormat:@"±%.2f m", vAccuracy];
    
    NSDate *currTime = [NSDate date];
    self.datetimeLabel.text = [UtilityFunc getStringFromDate:currTime byFormat:kDatetimeFormat];
}

- (void)showFailedMsgTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    [TSMessage showNotificationWithTitle:title
                                subtitle:subTitle
                                    type:TSMessageNotificationTypeWarning];
}

- (BOOL)checkRecordDataAndShowInvalidItemStatus
{
    BOOL isValid = YES;
    
    if (!StringNotEmpty(_recordModel.title))
    {
        isValid = NO;
        [UtilityFunc viewShowRedShadow:self.nameTxtField];
    }else{}
//    if (StringNotEmpty(_recordModel.address))
//    {
//        isValid = NO;
//        [UtilityFunc viewShowRedShadow:self.addressLabel];
//    }else{}
    if (!_recordModel.location)
    {
        isValid = NO;
        [UtilityFunc viewShowRedShadow:self.locationSwitchBtn];
    }else{}
    
    return isValid;
}

- (void)setupButtonUI:(UIButton *)btn
{
    btn.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    btn.layer.cornerRadius = 4.0f;
    btn.layer.borderWidth = 1.0f;
    btn.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
}

- (void)saveCurrRecord
{
    _lastSavedRecordTitle = _recordModel.title;
    [RecordStorageManagerObj saveRecord:_recordModel];
    
    [SGInfoAlert showAlert:@"保存成功" duration:0.3f inView:self.view];
}





























@end
