//
//  RecordDetailViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/13.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordDetailViewController.h"
#import "RecordModel.h"

@interface RecordDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *horizontalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *verticalAccuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *datetimeLabel;



@end

@implementation RecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"详情";
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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

@end
