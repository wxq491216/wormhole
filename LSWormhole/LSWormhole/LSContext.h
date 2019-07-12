//
//  LSContext.h
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import <Foundation/Foundation.h>
#import "LSResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSContext : NSObject

@property(nonatomic, strong, readonly)NSString* appName;

-(instancetype)initWithBundleId:(NSString*)bundleId;

//开始执行业务逻辑，空实现，子类需自己实现
-(void)go;

//处理返回数据包
-(void)handleResponse:(LSResponse*)response;

@end

NS_ASSUME_NONNULL_END
