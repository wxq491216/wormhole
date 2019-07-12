//
//  QQRobotOperation.m
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import "QQRobotTask.h"
#import "LSRunLoopThread.h"
#import "NSTask.h"
#import <objc/objc-runtime.h>

@interface QQRobotTask ()

//目标应用bundleId
@property(nonatomic, strong)NSString* bundleId;
//切换应用分身计时器
@property(nonatomic, strong)NSTimer* recordTimer;

@property(nonatomic, assign)NSInteger currentIndex;

@end

@implementation QQRobotTask

-(instancetype)initWithTargetApp:(NSString *)appId
{
    if (self = [super init]) {
        self.bundleId = appId;
    }
    return self;
}

-(void)start
{
    [super start];
    [self loop];
}

-(void)loop
{
    NSLog(@"wxq QQRobotTask loop");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self nextRecord];
        [NSThread sleepForTimeInterval:5.0f];
        [self openApp];
        self.currentIndex++;
        if (self.currentIndex < 0) {
            [self end];
        }
    });
}

-(void)addTimer
{
    self.recordTimer = [NSTimer timerWithTimeInterval:(10 * 60.0f) repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self loop];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
}

-(void)addPort
{
    NSLog(@"wxq QQRobotTask addPort");
}

//爱伪装切换下一条分身记录
-(void)nextRecord
{
    NSLog(@"wxq QQRobotTask nextRecord");
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/uiopen"];
    NSArray* argument = [NSArray arrayWithObjects:@"IGG://cmd/nextrecord", nil];
    [task setArguments:argument];
    [task launch];
    [task waitUntilExit];
}

//打开应用分身
-(void)openApp
{
    NSLog(@"wxq QQRobotTask openApp");
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    
    BOOL isInstall = [workspace performSelector:@selector(applicationIsInstalled:) withObject:self.bundleId];
    if (isInstall) {
        //通过bundle id。打开一个APP
        [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:self.bundleId];
    }else{
        NSLog(@"wxq 设备末安装App %@，请检查", self.bundleId);
    }
}

@end
