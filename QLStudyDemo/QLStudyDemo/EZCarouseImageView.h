//
//  EZCarouseImageView.h
//  QLStudyDemo
//
//  Created by xuqianlong on 15/6/13.
//  Copyright (c) 2015年 前沿科技. All rights reserved.

// EZ版本比EY版本性能更加好了，使用了collectionView；
// 仅仅使用了两个Cell来复用；EY最多使用了三个；


#import <UIKit/UIKit.h>

@class EZCarouseImageView;
@protocol EZCarouseImageViewDelegate <NSObject>

- (void)ezCarouseImageView:(EZCarouseImageView *)view didClickedImageView:(NSUInteger)idx;

@end

@interface EZCarouseImageView : UIView

//----------------相关配置----------------//

//auto scroll timeinterval；default is 2s
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

//是否允许自动滚动，default is YES；
@property (nonatomic, assign) bool allowAutoScroll;

//默认图片；
@property (nonatomic, strong) UIImage *placeHolderImage;

//点击代理；
@property (nonatomic, weak) id<EZCarouseImageViewDelegate>delegate;


/**
 *  初始化
 *
 *  @param frame frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动
 *
 *  @return instance
 */

- (instancetype)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;

/**
 *  数据源：urls,如果少于2个，不自动滚动
 */
- (void)resetEasyURLArr:(NSArray *)arr;

@end
