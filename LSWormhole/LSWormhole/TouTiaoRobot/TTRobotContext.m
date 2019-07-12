//
//  TTRobotContext.m
//  LSWormhole
//
//  Created by xqwang on 2019/6/24.
//

#import "TTRobotContext.h"
#import "TTRobotTask.h"
#import "LSDataFlowManager.h"
#import "LSResponse.h"
#import "TTRobotAppCompleteResponse.h"

@interface TTRobotContext ()

//@property(nonatomic, strong)NSOperationQueue* queue;
@property(nonatomic, strong)NSObject* lock;
//后台正在执行的任务
@property(nonatomic, strong)TTRobotTask* task;

@end


@implementation TTRobotContext

//+(instancetype)sharedContext
//{
//    static TTRobotContext* context = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        context = [[TTRobotContext alloc] init];
//    });
//    return context;
//}

-(instancetype)initWithBundleId:(NSString *)bundleId
{
    if (self = [super initWithBundleId:bundleId]) {
        self.lock = [[NSObject alloc] init];
        self.task = [[TTRobotTask alloc] initWithAppName:bundleId];
    }
    return self;
}

-(void)go
{
    [self.task start];
}

-(void)handleResponse:(LSResponse*)response
{
    TTRobotAppCompleteResponse* appResponse = (TTRobotAppCompleteResponse*)response;
    BOOL succ = [appResponse succ];
    NSLog(@"wxq 接收到App反馈信息，动作执行%@", succ? @"成功":@"失败");
    [self.task appCompleteSignal];
}

//-(void)listen
//{
//    [[LSDataFlowManager sharedManager] registerCommand:@"ToutiaoSimulationDevice" handleClassName:@"TTRobotCommand"];
//}
//
//-(void)addOperation:(NSOperation *)operation
//{
//    [self.queue addOperation:operation];
//    if ([operation isKindOfClass:[TTOperation class]]) {
//        @synchronized (self.lock) {
//            [self.operationList addObject:operation];
//        }
//    }
//}
//
//-(void)stopOperation:(NSString *)name
//{
//    @synchronized (self.lock) {
//        __block TTOperation* target = nil;
//        [self.operationList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            TTOperation* operation = (TTOperation*)obj;
//            if ([[operation operationName] isEqualToString:name]) {
//                [operation cancel];
//                *stop = YES;
//                target = operation;
//            }
//        }];
//        [self.operationList removeObject:target];
//    }
//}
//
//-(TTOperation*)operatonWithName:(NSString *)name
//{
//    NSLog(@"wxq name = %@", name);
//    __block TTOperation* operation = nil;
//    @synchronized (self.lock) {
//        [self.operationList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            TTOperation* item = (TTOperation*)obj;
//            NSLog(@"wxq operationName = %@", [item operationName]);
//            if ([[item operationName] isEqualToString:name]) {
//                operation = item;
//                *stop = YES;
//            }
//        }];
//    }
//    return operation;
//}

@end
