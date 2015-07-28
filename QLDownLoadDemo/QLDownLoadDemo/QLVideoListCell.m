//
//  QLVideoListCell.m
//  QLDownLoadDemo
//
//  Created by xuqianlong on 15/7/24.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLVideoListCell.h"
#import "QLVideoListModel.h"
#import "AFHTTPRequestOperation.h"

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

- (void)setOp:(AFHTTPRequestOperation *)op
{
    if (_op != op) {
        _op = op;
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            //            NSLog(@"-c:%.2fKb;a:%.2fKb;t:%.2fMb",bytesRead/1024.0,totalBytesRead/1024.0,totalBytesExpectedToRead/1024.0/1024.0);
            float progress = 1.0*totalBytesRead/totalBytesExpectedToRead;
//            NSLog(@"-p:%.2f",progress);
            self.downLoadPV.progress = progress;
        }];
    }
}
@end
