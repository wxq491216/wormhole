//
//  LSDataFlowManager.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/24.
//

#import "LSDataFlowManager.h"
#import "LSDeviceClient.h"
#import "LSDeviceServer.h"
#import "LSSocketHeader.h"
#import "LSCommand.h"
#import "LSResponse.h"
#import <UIKit/UIKit.h>

@interface LSDataFlowManager () <LSSocketDelegate>

@property(nonatomic, strong)LSDeviceServer* socketServer;
@property(nonatomic, strong)LSDeviceClient* socketClient;

//任务command注册中心
@property(nonatomic, strong)NSMutableDictionary* commandCenter;
//反馈response注册中心
@property(nonatomic, strong)NSMutableDictionary* responseCenter;
//同步锁
@property(nonatomic, strong)NSObject* lock;

//只能调用一次start接口
@property(nonatomic, assign)BOOL running;

//设备名称
@property(nonatomic, strong)NSString* name;
//设备服务的目标应用
@property(nonatomic, strong)NSString* app;
//应用是否打开
@property(nonatomic, assign, getter=isAppOpen)BOOL appOpen;
//在App打开之前接收到的需要下发到App的缓存数据，在App打开之后立即下发
@property(nonatomic, strong)NSMutableData* pendingMessage;

@end


@implementation LSDataFlowManager

+(instancetype)sharedManager
{
    static LSDataFlowManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LSDataFlowManager alloc] init];
    });
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.socketServer = [[LSDeviceServer alloc] initWithPort:LOCAL_SERVER_PORT];
        [self.socketServer setDelegate:self];
        self.socketClient = [[LSDeviceClient alloc] init];
        [self.socketClient setDelegate:self];
        
        self.lock = [[NSObject alloc] init];
        self.pendingMessage = [NSMutableData data];
        self.commandCenter = [NSMutableDictionary dictionary];
        self.responseCenter = [NSMutableDictionary dictionary];
        
        //应用打开命令响应类
        [self registerCommand:@"openApp" handleClassName:@"LSOpenAppCommand"];
        //QQ自动游览
        [self registerCommand:@"QQRobotAutoScan" handleClassName:@"QQRobotCommand"];
        //头条模拟设备
        [self registerCommand:@"ToutiaoSimulationDevice" handleClassName:@"TTRobotCommand"];
        //身份识别反馈包响应类
        [self registerResponse:@"identyVerify" handleClassName:@"LSIdentifyResponse"];
    }
    return self;
}

-(void)updatePhoneName:(NSString*)name targetApp:(NSString*)app
{
    self.name = name;
    self.app = app;
}

-(void)start
{
    if (self.running) {
        return;
    }
    [self.socketClient connectServer];
    [self.socketServer startServer];
    self.running = YES;
}

-(void)setContext:(LSContext *)context
{
    if (self.context == nil) {
        _context = context;
    }
}

-(void)registerCommand:(NSString *)commandName handleClassName:(NSString *)className
{
    @synchronized (self.lock) {
        [self.commandCenter setValue:className forKey:commandName];
    }
}

-(void)unregisterCommand:(NSString *)commandName
{
    @synchronized (self.lock) {
        [self.commandCenter removeObjectForKey:commandName];
    }
}

-(void)registerResponse:(NSString *)responseName handleClassName:(NSString*)handleClassName
{
    @synchronized (self.lock) {
        [self.responseCenter setValue:handleClassName forKey:responseName];
    }
}

-(void)unregisterResponse:(NSString *)responseName
{
    @synchronized (self.lock) {
        [self.responseCenter removeObjectForKey:responseName];
    }
}

//构建身份反馈包数据
-(NSData*)createIdentifyData
{
    NSString* deviceName = [[UIDevice currentDevice] name];
    NSDictionary* identifyInfo = @{
                                   @"userName" : self.name,
                                   @"type" : @(1),
                                   @"app" : self.app,
                                   @"deviceName" : deviceName
                                   };
    NSData* identifyData = [NSJSONSerialization dataWithJSONObject:identifyInfo options:0 error:nil];
    
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_IDENTIFY_PACKAGE);
    head.nLen = CFSwapInt32((unsigned int)[identifyData length]);
    NSData* identifyHeadData = [NSData dataWithBytes:&head length:PacketHeadSize];
    
    NSMutableData* data = [NSMutableData dataWithData:identifyHeadData];
    [data appendData:identifyData];
    return data;
}

//构建命令包处理对象
-(LSCommand*)createCommand:(NSDictionary*)info
{
    LSCommand* command = nil;
    NSString* name = [info valueForKey:@"name"];
    NSDictionary* values = [info valueForKey:@"params"];
    @synchronized (self.lock) {
        NSString* commandName = [self.commandCenter valueForKey:name];
        command = [[NSClassFromString(commandName) alloc] initWithName:name info:values];
    }
    return command;
}

//构建反馈包数据
-(NSData*)createCommandResponseData:(NSData*)data
{
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_RESPONSE_PACKAGE);
    head.nLen = CFSwapInt32((unsigned int)[data length]);
    
    NSMutableData* commandData = [NSMutableData data];
    [commandData appendData:[NSData dataWithBytes:&head length:PacketHeadSize]];
    [commandData appendData:data];
    return commandData;
}


//构建反馈数据处理对象
-(LSResponse*)createResponse:(NSDictionary*)info
{
    id response = nil;
    NSString* responseName = [info valueForKey:@"name"];
    @synchronized (self.lock) {
        NSString* handleClassName = [self.responseCenter valueForKey:responseName];
        Class handleClass = NSClassFromString(handleClassName);
        if (handleClass != nil) {
            response = [[handleClass alloc] initWithDictionary:info];
        }
        
    }
    return response;
}

//处理反馈数据
-(void)handleResponseData:(NSData*)data
{
    NSError* error = nil;
    NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    LSResponse* response = [self createResponse:body];
    if (response != nil) {
        [self.context handleResponse:response];
    }else{
        NSLog(@"wxq 末找到合适的response处理类");
    }
}

//向目标app发送普通算法请求
-(void)sendToAppNormalData:(NSData*)message
{
    if ([self isAppOpen]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.socketServer sendData:message];
        });
    }else{
        NSDictionary* openInfo = @{
                                   @"name" : @"openApp",
                                   @"params" : @{
                                           @"bundleId" : self.app,
                                           }
                                   };
        LSCommand* command = [self createCommand:openInfo];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [command runCommand:nil];
        });
        //缓存数据
        @synchronized (self.lock) {
            [self.pendingMessage appendData:message];
        }
    }
}

//本机Socket服务器有新的连接时，表示App已经成功打开
-(void)socketDidConnect:(id)sock
{
    if ([sock isEqual:self.socketServer]) {
        self.appOpen = YES;
        @synchronized (self.lock) {
            NSLog(@"wxq 发送缓存的普通数据包到应用");
            if ([self.pendingMessage length] == 0) {
                return;
            }
            [self.socketServer sendData:[self.pendingMessage copy]];
            [self.pendingMessage setLength:0];
        }
    }
}

-(void)socket:(id)sock didReceiveNormalData:(NSData *)data
{
    if ([sock isEqual:self.socketServer]) {
        NSLog(@"wxq 发送普通数据包到远程服务器");
        [self.socketClient sendData:data];
    }else if ([sock isEqual:self.socketClient]){
        NSLog(@"wxq 发送普通数据包到应用");
        [self sendToAppNormalData:data];
    }
}

-(void)socket:(id)sock didReceiveCommand:(NSData*)commandData
{
    NSError* error = nil;
    NSDictionary* info = [NSJSONSerialization JSONObjectWithData:commandData options:0 error:&error];
    if (error == nil) {
        NSLog(@"wxq 接收到的命令数据为%@", info);
        LSCommand* command = [self createCommand:info];
        if (command) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [command runCommand:^(BOOL succ, NSData *data) {
                    NSData* responseData = [self createCommandResponseData:data];
                    [sock sendData:responseData];
                }];
            });
        }else{
            NSLog(@"wxq 构建命令处理类失败，请检查");
        }
    }else{
        NSLog(@"wxq 命令包数据按JSON格式解析失败，请检查");
    }
}

-(void)socket:(id)sock didReceiveResponse:(NSData*)data
{
    if ([sock isEqual:self.socketServer]) {
        NSLog(@"wxq 接收到应用发送的反馈数据");
    }else if ([sock isEqual:self.socketClient]){
        NSLog(@"wxq 接收到服务器发送的反馈数据");
    }
    [self handleResponseData:data];
}

-(void)socket:(id)sock didLostConnection:(NSError *)error
{
    if([sock isEqual:self.socketServer]){
        self.appOpen = NO;
    }
}

@end
