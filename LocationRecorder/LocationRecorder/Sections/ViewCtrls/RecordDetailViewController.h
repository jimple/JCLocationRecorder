//
//  RecordDetailViewController.h
//  LocationRecorder
//
//  Created by jimple on 14/8/13.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordDetailViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *recordArray;
@property (nonatomic, assign) NSUInteger recordIndex;

@end
