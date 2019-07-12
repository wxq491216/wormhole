//
//  TTOperation.h
//  LSWormhole
//
//  Created by xqwang on 2019/6/24.
//

#import "LSRunLoopThread.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTRobotTask : LSRunLoopThread

-(instancetype)initWithAppName:(NSString*)appName;

@property(nonatomic, strong)NSString* operationName;

-(void)appCompleteSignal;

@end

NS_ASSUME_NONNULL_END
