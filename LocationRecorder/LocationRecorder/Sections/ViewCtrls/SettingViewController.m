//
//  SettingViewController.m
//  LocationRecorder
//
//  Created by jimple on 14/8/17.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

#import "SettingViewController.h"
#import "SIAlertView.h"
#import "RecordStorageManager.h"
#import "SGInfoAlert+ShowAlert.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"设置";
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
    return 1;
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

#pragma mark -
- (IBAction)removeAllRecords:(id)sender
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"提示" andMessage:@"删除所有记录，本操作将无法恢复！\n确定删除？"];
    alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromTop;
    @weakify(self);
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"删除"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              @strongify(self);
                              [self removeAllRecord];
                          }];
    [alertView show];
}

- (void)removeAllRecord
{
    [RecordStorageManagerObj removeAllRecords];
    [SGInfoAlert showAlert:@"删除成功" duration:0.5f inView:self.view];
}


- (IBAction)sendAllRecordByEmail:(id)sender
{
    NSString *_kmlFilename = [RecordStorageManagerObj createKMLfileFromRecords];
    
    NSString *kmlData = [[NSString alloc]initWithContentsOfFile:_kmlFilename encoding:NSUTF8StringEncoding error:nil];
    if (kmlData)
    {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        if(mailCompose)
        {
            //设置代理
            [mailCompose setMailComposeDelegate:self];
            
            NSArray *toAddress = [NSArray arrayWithObject:@""];
            NSArray *ccAddress = [NSArray arrayWithObject:@""];;
            NSString *emailBody = @"<H1>点位信息KML文件</H1>";
            
            //设置收件人
            [mailCompose setToRecipients:toAddress];
            //设置抄送人
            [mailCompose setCcRecipients:ccAddress];
            //设置邮件内容
            [mailCompose setMessageBody:emailBody isHTML:YES];
            
            //设置邮件主题
            [mailCompose setSubject:@"这里是主题"];
            //设置邮件附件{mimeType:文件格式|fileName:文件名}
            NSData* pData = [[NSData alloc]initWithContentsOfFile:_kmlFilename];
            [mailCompose addAttachmentData:pData mimeType:@"txt" fileName:@"points.kml"];
            //设置邮件视图在当前视图上显示方式
            [self presentModalViewController:mailCompose animated:YES];
        }
    }
    
    [SGInfoAlert showAlert:@"邮件发送成功" duration:0.5f inView:self.view];
    
    //如何删除已经发送成功的KML文件？

    
    
    
}
































@end
