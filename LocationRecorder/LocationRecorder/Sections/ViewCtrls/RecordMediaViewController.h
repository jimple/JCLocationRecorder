//
//  RecordMediaViewController.h
//  LocationRecorder
//
//  Created by jimple on 14/8/24.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RecordMediaVCResetImgArrayHandler)(NSArray *newImgFilePathArray);

@interface RecordMediaViewController : UITableViewController

@property (nonatomic, copy) RecordMediaVCResetImgArrayHandler resetImgArrHandler;


- (void)setImgFilePathArray:(NSArray *)imgPathArray;


@end
