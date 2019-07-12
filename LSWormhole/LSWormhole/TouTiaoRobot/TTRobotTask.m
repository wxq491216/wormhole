//
//  TTOperation.m
//  LSWormhole
//
//  Created by xqwang on 2019/6/24.
//

#import "TTRobotTask.h"
#import "NSTask.h"
#import <objc/message.h>

@interface TTRobotTask ()<NSMachPortDelegate>

@property(nonatomic, retain)NSPort* recordPort;

//应用动作结束信号
@property(nonatomic, strong)NSCondition* appCondition;
//目标App
@property(nonatomic, copy)NSString* appName;
//新建设备的数量
@property(nonatomic, assign)NSInteger count;

@end


@implementation TTRobotTask

-(instancetype)initWithAppName:(NSString*)appName
{
    if (self = [super init]) {
        self.count = 99;
        self.appName = appName;
        self.recordPort = [NSMachPort port];
        [self.recordPort setDelegate:self];
        self.appCondition = [[NSCondition alloc] init];
    }
    return self;
}

-(void)addPort
{
    [[NSRunLoop currentRunLoop] addPort:self.recordPort forMode:NSDefaultRunLoopMode];
}

-(void)loop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"wxq 头条系任务执行第%d次", (int)self.count);
        if(self.count >= 100){
            [self cleanDevice];
                //清空所有记录，当前进程睡眠30秒
            [NSThread sleepForTimeInterval:30.0f];
            self.count = 0;
        }
        [self createNewDeivce];
        //一键新机5秒后执行打开APP操作
        [NSThread sleepForTimeInterval:5.0f];
        [self openApp:self.appName];
        self.count++;
        BOOL ret = [self.appCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:(2 * 60.0f)]];
        if (ret) {
            [self postMessage:@"complete"];
        }else{
            [self postMessage:@"timeout"];
        }
    });
}

-(void)handleMachMessage:(void *)msg
{
    NSArray* info = (__bridge NSArray*)msg;
    NSString* message = [info firstObject];
    NSLog(@"wxq receive message = %@", message);
    [self loop];
}

-(void)postMessage:(NSString*)message
{
    NSMutableArray* info = [NSMutableArray arrayWithObjects:message, nil];
    [self.recordPort sendBeforeDate:[NSDate date] components:info from:nil reserved:0];
}

//爱伪装一键新机
-(void)createNewDeivce
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/uiopen"];
    NSArray* argument = [NSArray arrayWithObjects:@"IGG://cmd/newrecord", nil];
    [task setArguments:argument];
    [task launch];
    [task waitUntilExit];
}

//爱伪装历史沙盒文件清理
-(void)cleanDevice
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/uiopen"];
    NSArray* argument = [NSArray arrayWithObjects:@"IGG://cmd/deleteallrecords", nil];
    [task setArguments:argument];
    [task launch];
    [task waitUntilExit];
}

//打开指定应用
-(void)openApp:(NSString*)bundleId
{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    
    BOOL isInstall = [workspace performSelector:@selector(applicationIsInstalled:) withObject:self.appName];
    if (isInstall) {
        //通过bundle id打开一个APP
        [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:self.appName];
    }else{
        NSLog(@"wxq 设备末安装App %@，请检查", self.appName);
    }
}

-(void)appCompleteSignal
{
    [self.appCondition lock];
    [self.appCondition signal];
    NSLog(@"wxq App完结信号成功发送");
    [self.appCondition unlock];
}

-(NSData*)createCompleteData
{
    NSDictionary* info = @{
                           @"bundleId" : self.appName,
                           @"command" : @"ToutiaoSimulationDevice"
                           };
    NSData* data = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
    return data;
}

@end
