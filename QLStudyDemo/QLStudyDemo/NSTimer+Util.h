//
//  NSTimer+Util.h
//  轮播图
//
//  Created by Qianlong Xu on 15-1-7.
//  Copyright (c) 2015年 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Util)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end
