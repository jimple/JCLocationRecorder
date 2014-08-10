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

@interface LocationTableViewController ()
<
    CLLocationManagerDelegate
>

@property (nonatomic, weak) IBOutlet UITextField *nameTxtField;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *horizontalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *verticalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *datetimeLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *refreshingIndicator;
@property (nonatomic, weak) IBOutlet UILabel *refreshingTipsLabel;
@property (nonatomic, weak) IBOutlet UIButton *locationSwitchBtn;

@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _locationMgr = [[CLLocationManager alloc] init];
    _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    _locationMgr.delegate = self;
    
    // UI
    [self.locationSwitchBtn setTitle:@"开始定位" forState:UIControlStateNormal];
    [self.locationSwitchBtn setTitle:@"停止定位" forState:UIControlStateSelected];
    [self.locationSwitchBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.refreshingIndicator.hidden = YES;
    self.refreshingTipsLabel.hidden = YES;
    
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
    return 8;
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

- (IBAction)saveBtn:(id)sender
{
    
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    [self showLocationInfo:newLocation];
    
    // 坐标取地址
    // gps坐标转谷歌坐标
    CLLocationCoordinate2D objGoogleLoc = [TransformCorrdinate GPSLocToGoogleLoc:newLocation.coordinate];
    CLLocation *locToGetGeo = [[CLLocation alloc] initWithLatitude:objGoogleLoc.latitude longitude:objGoogleLoc.longitude];
    _geocoder = [[CLGeocoder alloc] init];
    [_geocoder reverseGeocodeLocation:locToGetGeo completionHandler:^(NSArray *arrPlaceMarks, NSError *err)
     {
         if (arrPlaceMarks && (arrPlaceMarks.count > 0))
         {
             CLPlacemark *objPlace = [arrPlaceMarks objectAtIndex:0];
             
             NSLog(@"\n\n\naddress\n%@\n\n\n", [objPlace.addressDictionary description]);
             
             NSString *city = [objPlace.addressDictionary objectForKey:@"City"];
             NSString *street = [objPlace.addressDictionary objectForKey:@"Street"];
             NSString *subLocality = [objPlace.addressDictionary objectForKey:@"SubLocality"];
             NSString *name = [objPlace.addressDictionary objectForKey:@"Name"];
             self.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", city, subLocality, street, name];
         }
         else
         {
             // 地址获取失败
             self.addressLabel.text = @"获取地址失败";
         }
     }];
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    [self showFailedMsgTitle:@"获取坐标失败。" subTitle:error.localizedDescription];
}

#pragma mark -
- (BOOL)isLocationServicesEnabled
{
    return ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied));
}

- (void)showLocationInfo:(CLLocation *)location
{
    float altitude = location.altitude;
    float latitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    float hAccuracy = location.horizontalAccuracy;
    float vAccuracy = location.verticalAccuracy;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.5f", latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.5f", longitude];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%.2f m", altitude];
    self.horizontalAccuracyLabel.text = [NSString stringWithFormat:@"%.5f", hAccuracy];
    self.verticalAccuracyLabel.text = [NSString stringWithFormat:@"%.2f m", vAccuracy];
    
    NSDate *currTime = [NSDate date];
    self.datetimeLabel.text = [UtilityFunc getStringFromDate:currTime byFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)showFailedMsgTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    [TSMessage showNotificationWithTitle:title
                                subtitle:subTitle
                                    type:TSMessageNotificationTypeWarning];
}

















@end
