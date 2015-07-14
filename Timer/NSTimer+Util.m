//
//  NSTimer+Util.m
//  轮播图
//
//  Created by Qianlong Xu on 15-1-7.
//  Copyright (c) 2015年 Demo. All rights reserved.
//

#import "NSTimer+Util.h"

@implementation NSTimer (Util)

+ (NSTimer *)scheduledWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void (^)())block
{
   return [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(ql_blockInvoke:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)ql_blockInvoke:(NSTimer *)sender
{
    void (^block)() = sender.userInfo;
    if (block) {
        block();
    }
}

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
