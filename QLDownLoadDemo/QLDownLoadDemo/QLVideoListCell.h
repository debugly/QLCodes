//
//  QLVideoListCell.h
//  QLDownLoadDemo
//
//  Created by xuqianlong on 15/7/24.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QLVideoListModel,AFHTTPRequestOperation;
@interface QLVideoListCell : UITableViewCell

@property (nonatomic, weak) QLVideoListModel *model;
@property (nonatomic, weak) AFHTTPRequestOperation *op;

@end
