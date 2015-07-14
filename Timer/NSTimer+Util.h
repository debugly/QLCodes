//
//  NSTimer+Util.h
//  轮播图
//
//  Created by Qianlong Xu on 15-1-7.
//  Copyright (c) 2015年 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Util)

//创建timer，block回调
+ (NSTimer *)scheduledWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)())block;
//暂停；
- (void)pauseTimer;
//复位；
- (void)resumeTimer;
//delay interval 之后复位；
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end
