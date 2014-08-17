//
//  RecordListCell.m
//  LocationRecorder
//
//  Created by jimple on 14/8/13.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "RecordListCell.h"

@implementation RecordListCell

+ (CGFloat)cellHeight
{
    return 95.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
