//
//  RecordImgCell.h
//  LocationRecorder
//
//  Created by jimple on 14/8/24.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordImgCell : UITableViewCell

+ (CGFloat)cellHeight;


@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *fileNameLabel;



@end
