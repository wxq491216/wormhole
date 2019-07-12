//
//  TTRobotAppCompleteResponse.h
//  LSWormhole
//  头条系app本地获取设备参数并成功上报后反馈来的信息
//  Created by xqwang on 2019/6/25.
//

#import "LSResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTRobotAppCompleteResponse : LSResponse

@property(nonatomic, readonly, assign)BOOL succ;

@end

NS_ASSUME_NONNULL_END
