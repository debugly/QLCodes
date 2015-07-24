//
//  QLVideoListModel.h
//  QLDownLoadDemo
//
//  Created by xuqianlong on 15/7/24.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "YQBaseModel.h"

@interface QLVideoListModel : YQBaseModel

@property (nonatomic, copy) NSString *video_name;
@property (nonatomic, copy) NSString *video_url;

@property (nonatomic, assign) bool downLoading;

@end
