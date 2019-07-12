//
//  QQRobotOperation.h
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import <Foundation/Foundation.h>
#import "LSRunLoopThread.h"

NS_ASSUME_NONNULL_BEGIN

@interface QQRobotTask : LSRunLoopThread

-(instancetype)initWithTargetApp:(NSString*)appId;

@end

NS_ASSUME_NONNULL_END
