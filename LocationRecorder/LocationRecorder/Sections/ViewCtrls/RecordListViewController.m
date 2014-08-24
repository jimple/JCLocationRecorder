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
#import "SGInfoAlert+ShowAlert.h"

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
    
//    [self refreshTable];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshTable];
}

#pragma mark - Action
- (IBAction)refreshList:(id)sender
{
    [self refreshTable];
    
    if (_recordArray.count > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{}
    [SGInfoAlert showAlert:@"刷新完成" duration:0.3f inView:self.view];
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
    
    NSUInteger index = [self arrayIndexFromTableIndexPath:indexPath];
    RecordModel *record = _recordArray[index];
    cell.titleLabel.text = record.title;
    cell.locationLabel.text = [NSString stringWithFormat:@"%.6f  %.6f", record.location.coordinate.longitude, record.location.coordinate.latitude];
    cell.altitudeLabel.text = [NSString stringWithFormat:@"%.2f m (±%.2fm)", record.location.altitude, record.location.verticalAccuracy];
    cell.dateTimeLabel.text = [UtilityFunc getStringFromDate:[NSDate dateWithTimeIntervalSince1970:record.recordTime.doubleValue] byFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.indexLabel.text = [NSString stringWithFormat:@"%d", index+1];
    
    cell.imageView.image = [UIImage imageNamed:@"DefaultImg"];
    
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
        
        [_recordArray removeObjectAtIndex:[self arrayIndexFromTableIndexPath:indexPath]];
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
    
    [self performSegueWithIdentifier:@"SegueRecordDetail" sender:@([self arrayIndexFromTableIndexPath:indexPath])];
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

- (NSUInteger)arrayIndexFromTableIndexPath:(NSIndexPath *)indexPath
{
    APP_ASSERT(_recordArray && indexPath);
    
    // 逆序显示
    return (_recordArray.count - indexPath.row - 1);
}


























@end
