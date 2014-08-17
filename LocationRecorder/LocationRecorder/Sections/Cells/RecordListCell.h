//
//  RecordListCell.h
//  LocationRecorder
//
//  Created by jimple on 14/8/13.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordListCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@end
