//
//  LSThread.h
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface LSRunLoopThread : NSThread

//向线程RunLoop中添加计时器
-(void)addTimer;

//向线程RunLoop中添加消息源
-(void)addPort;

//结束线程运行
-(void)end;

@end

NS_ASSUME_NONNULL_END
