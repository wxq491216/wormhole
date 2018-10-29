//
//  LSNetworkManager.m
//  AwemePlugin
//
//  Created by xqwang on 2018/9/25.
//

#import "LSNetworkManager.h"
#import "GCDAsyncSocket.h"
#import "LSDoTaskCommand.h"
#import "QYPluginPlayerManager.h"
#import <UIKit/UIKit.h>

@interface LSNetworkManager ()<GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket* socket;
@property(nonatomic, strong)NSTimer* heartTimer;
@property(nonatomic, strong)NSMutableData* buffer;
@property(nonatomic, assign)NSUInteger writeTag;
@property(nonatomic, assign)BOOL connected;

@end

@implementation LSNetworkManager

-(instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageComplete:) name:DO_TASK_COMMAND_COMPLETE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appPause:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResume:) name:UIApplicationWillEnterForegroundNotification object:nil];
        dispatch_queue_t queue = dispatch_queue_create("AwemeSocket's queue", DISPATCH_QUEUE_CONCURRENT);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        self.buffer = [NSMutableData data];
        self.writeTag = 0;
    }
    return self;
}

-(void)appResume:(NSNotification*)notification
{
    [self connectServer];
}

-(void)appPause:(NSNotification*)notification
{
    [self disconnectSever];
}

-(void)handleMessageComplete:(NSNotification*)notification
{
    NSLog(@"wxq command成功完成");
    NSDictionary* info = (NSDictionary*)[notification object];
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    [self sendData:data];
}

-(void)connectServer
{
    if (self.socket) {
        NSError* error = nil;
        [self.socket connectToHost:@"localhost" onPort:22346 withTimeout:60.0f error:&error];
        if (error != nil) {
            NSLog(@"wxq socket connect server error with %@", error);
        }
        NSLog(@"wxq socket connect server complete");
    }
}

-(void)disconnectSever
{
    if (self.socket) {
        [self.socket disconnect];
        [self.socket setUserData:@(SOCKET_OFFLINE_BY_USER)];
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
}

-(void)sendData:(NSData*)data
{
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_NORMAL_PACKAGE);
    head.nLen = CFSwapInt32((unsigned int)[data length]);
    NSMutableData* packageData = [NSMutableData dataWithBytes:&head length:PacketHeadSize];
    [packageData appendData:data];
    [self.socket writeData:packageData withTimeout:-1 tag:-1];
    NSLog(@"wxq 发送到服务端%lu号数据", self.writeTag++);
}

//心跳
-(void)heartbeatPackage:(NSTimer*)timer
{
    NSLog(@"wxq 应用发送心跳包");
    if([self.socket isConnected]){
        struct tagNetPacketHead head;
        head.version = CFSwapInt32(1);
        head.type = CFSwapInt32(ID_HEART_BEAT_PACKAGE);
        head.nLen = CFSwapInt32(0);
        NSData* heartBeatData = [NSData dataWithBytes:&head length:PacketHeadSize];
        [self.socket writeData:heartBeatData withTimeout:-1 tag:-1];
    }else{
        NSLog(@"应用侧socket已丢失连接");
    }
}

-(void)preHandleData:(NSData*)data
{
    @synchronized(self){
        if (self.buffer == nil) {
            self.buffer = [NSMutableData data];
        }
        [self.buffer appendData:data];
        
        struct tagNetPacketHead header;
        [self.buffer getBytes:&header range:NSMakeRange(0, PacketHeadSize)];
        header.version = CFSwapInt32BigToHost(header.version);
        header.type = CFSwapInt32BigToHost(header.type);
        header.nLen = CFSwapInt32BigToHost(header.nLen);
        NSUInteger lenght = [data length];
        NSUInteger bodyLength = header.nLen;
        NSUInteger left = lenght - PacketHeadSize;
        NSUInteger start = 0;
        while (left >= bodyLength) {
            start += PacketHeadSize;
            NSData* subData = [[self.buffer subdataWithRange:NSMakeRange(start, bodyLength)] copy];
            LSDoTaskCommand* command = [[LSDoTaskCommand alloc] initWithData:subData];
            [[QYPluginPlayerManager sharedManager] addTask:command];
            start += bodyLength;
            left = lenght - start;
            if (left <= PacketHeadSize) {
                break;
            }
            [data getBytes:&header range:NSMakeRange(start, PacketHeadSize)];
            left = lenght - start - PacketHeadSize;
            bodyLength = header.nLen;
        }
        [self.buffer replaceBytesInRange:NSMakeRange(0, start) withBytes:NULL length:0];
    }
}


-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"wxq socket connected server %@:%d", host, port);
    if (self.heartTimer == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(heartbeatPackage:) userInfo:nil repeats:YES];
        });
    }
    //读数据
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"wxq 接收到服务端发送的%ld号数据", tag);
    [self preHandleData:data];
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"wxq 成功向服务端发送数据");
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (self.heartTimer) {
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
    
    int state = [[sock userData] intValue];
    NSLog(@"wxq socket丢失连接 state = %d error=%@", state, err);
    //服务器掉线重连
    if (state == SOCKET_OFFLINE_BY_SERVER) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*60*NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self connectServer];
        });
    }
}

@end
