//
//  LSThread.m
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import "LSRunLoopThread.h"

@interface LSRunLoopThread ()

@property(nonatomic, assign, getter=isCompleted)BOOL completed;

@end

@implementation LSRunLoopThread

-(void)main
{
    @autoreleasepool {
        [self addTimer];
        [self addPort];
        while (![self isCompleted]) {
            NSLog(@"wxq LSRunLoopThread main");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

-(void)addTimer
{
    NSLog(@"wxq LSRunLoopThread子类需自行实现addTimer接口");
}

-(void)addPort
{
    NSLog(@"wxq LSRunLoopThread子类需自行实现addPort接口");
}

-(void)end
{
    self.completed = YES;
}

@end
