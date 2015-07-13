//
//  NSTimer+Util.m
//  轮播图
//
//  Created by Qianlong Xu on 15-1-7.
//  Copyright (c) 2015年 Demo. All rights reserved.
//

#import "NSTimer+Util.h"

@implementation NSTimer (Util)

- (void)pauseTimer
{
    if (!self.isValid) {
        return;
    }
    [self setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

- (void)resumeTimer
{
    [self resumeTimerAfterTimeInterval:0];
}

@end
