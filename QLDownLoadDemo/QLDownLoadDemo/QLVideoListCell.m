//
//  QLVideoListCell.m
//  QLDownLoadDemo
//
//  Created by xuqianlong on 15/7/24.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLVideoListCell.h"
#import "QLVideoListModel.h"

@interface QLVideoListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *downLoadTripLB;

@property (weak, nonatomic) IBOutlet UIProgressView *downLoadPV;

@end

@implementation QLVideoListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.downLoadTripLB.text = nil;
}

- (void)setModel:(QLVideoListModel *)model
{
    if (_model != model) {
        _model = model;
        self.titleLabel.text = model.video_name;
    }
}

@end
