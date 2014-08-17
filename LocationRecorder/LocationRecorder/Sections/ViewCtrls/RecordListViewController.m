//
//  RecordListViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/9.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordListViewController.h"
#import "RecordListCell.h"
#import "RecordStorageManager.h"
#import "RecordModel.h"
#import "RecordDetailViewController.h"

@interface RecordListViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *recordArray;

@end

@implementation RecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"列表";
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshTable];
}

#pragma mark - Action
- (IBAction)refreshList:(id)sender
{
    [self refreshTable];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _recordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordListCell" forIndexPath:indexPath];
    
    RecordModel *record = _recordArray[indexPath.row];
    cell.titleLabel.text = record.title;
    cell.locationLabel.text = [NSString stringWithFormat:@"%.6f  %.6f", record.location.coordinate.longitude, record.location.coordinate.latitude];
    cell.altitudeLabel.text = [NSString stringWithFormat:@"%.2f m", record.location.altitude];
    cell.dateTimeLabel.text = [UtilityFunc getStringFromDate:[NSDate dateWithTimeIntervalSince1970:record.recordTime.doubleValue] byFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [_recordArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [RecordStorageManagerObj resetRecords:_recordArray];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RecordListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self performSegueWithIdentifier:@"SegueRecordDetail" sender:@(indexPath.row)];
}

#pragma mark -
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueRecordDetail"] && sender)
    {
        NSNumber *index = (NSNumber *)sender;
        ((RecordDetailViewController *)segue.destinationViewController).recordArray = _recordArray;
        ((RecordDetailViewController *)segue.destinationViewController).recordIndex = index.integerValue;
    }else{}
}

- (void)refreshTable
{
    _recordArray = [[NSMutableArray alloc] initWithArray:[RecordStorageManagerObj allRecords]];
    _tableView.separatorStyle = (_recordArray.count > 0) ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    [_tableView reloadData];
}



























@end
