//
//  RecordMediaViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/24.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordMediaViewController.h"
#import "RecordImgCell.h"
#import "RecordStorageManager.h"
#import "PhotoDetailViewController.h"
#import "SGInfoAlert+ShowAlert.h"

@interface RecordMediaViewController ()

@property (nonatomic, weak) IBOutlet UIButton *editBtn;

@property (nonatomic, strong) NSMutableArray *imgFilePathArr;


@end

@implementation RecordMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    APP_ASSERT(_imgFilePathArr && self.resetImgArrHandler);
    
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editBtn setTitle:@"完成" forState:UIControlStateSelected];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImgFilePathArray:(NSArray *)imgPathArray
{
    _imgFilePathArr = [[NSMutableArray alloc] initWithArray:imgPathArray];
}

- (IBAction)editBtn:(id)sender
{
    self.tableView.editing = !self.tableView.editing;
    self.editBtn.selected = self.tableView.editing;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _imgFilePathArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordImgCell" forIndexPath:indexPath];
    
    NSString *fileName = _imgFilePathArr[indexPath.row];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [RecordStorageManager imgFolderPath], fileName];
    NSString *thumbFilePath = [NSString stringWithFormat:@"%@/%@", [RecordStorageManager imgFolderPath], [RecordStorageManager thumbFileNameByFileName:fileName]];
    BOOL fileExist = [UtilityFunc isFileExist:filePath];
    if (fileExist)
    {
        if ([UtilityFunc isFileExist:thumbFilePath])
        {
            cell.imgView.image = [UIImage imageWithContentsOfFile:thumbFilePath];
        }
        else
        {
            cell.imgView.image = [UIImage imageWithContentsOfFile:filePath];
        }
        
        cell.fileNameLabel.text = fileName;
        cell.fileNameLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.imgView.image = nil;
        cell.fileNameLabel.text = [NSString stringWithFormat:@"文件不存在  - %@", fileName];
        cell.fileNameLabel.textColor = [UIColor redColor];
    }
    
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
        
        [tableView beginUpdates];
        [_imgFilePathArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        if (self.resetImgArrHandler)
        {
            self.resetImgArrHandler(_imgFilePathArr);
        }else{}
        
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


#pragma mark - UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RecordImgCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *fileName = _imgFilePathArr[indexPath.row];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [RecordStorageManager imgFolderPath], fileName];
    UIImage *img;
    BOOL fileExist = [UtilityFunc isFileExist:filePath];
    if (fileExist)
    {
        img = [UIImage imageWithContentsOfFile:filePath];
        [self performSegueWithIdentifier:@"SeguePhotoDetail" sender:img];
    }
    else
    {
        [SGInfoAlert showAlert:@"文件不存在" duration:0.3f inView:self.view];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SeguePhotoDetail"])
    {
        APP_ASSERT(sender);
        UIImage *img = (UIImage *)sender;
        
        ((PhotoDetailViewController *)segue.destinationViewController).img = img;
    }
}






















@end
