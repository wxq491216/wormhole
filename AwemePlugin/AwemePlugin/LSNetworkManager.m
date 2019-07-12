//
//  LSNetworkManager.m
//  AwemePlugin
//
//  Created by xqwang on 2018/9/25.
//

#import "LSNetworkManager.h"
#import "GCDAsyncSocket.h"
#import "LSDoTaskCommand.h"
#import <UIKit/UIKit.h>

@interface LSNetworkManager ()<GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket* socket;
@property(nonatomic, strong)NSTimer* heartTimer;
@property(nonatomic, strong)NSMutableData* buffer;
@property(nonatomic, assign)NSUInteger writeTag;
@property(nonatomic, assign)BOOL connected;

@end

@implementation LSNetworkManager

+(instancetype)sharedManager
{
    static LSNetworkManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LSNetworkManager alloc] init];
    });
    return manager;
}

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

-(BOOL)connectServer
{
    BOOL succ;
    if (self.socket) {
        NSError* error = nil;
        succ = [self.socket connectToHost:@"localhost" onPort:LOCAL_SERVER_PORT withTimeout:60.0f error:&error];
        NSLog(@"wxq socket connect server succ = %d", succ);
        if (error != nil) {
            succ = NO;
        }
    }
    return succ;
}

-(void)reconnectServer
{
    [self.socket setDelegate:nil];
    [self.socket disconnect];
    
    [self.socket setDelegate:self];
    NSError* error = nil;
    [self.socket connectToHost:@"localhost" onPort:LOCAL_SERVER_PORT error:&error];
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
    head.version = 1;
    head.type = ID_NORMAL_PACKAGE;
    head.nLen = (unsigned int)[data length];
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
        head.version = 1;
        head.type = ID_HEART_BEAT_PACKAGE;
        head.nLen = 0;
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
        
        NSUInteger version = header.version;
        NSUInteger lenght = [data length];
        NSUInteger bodyLength = header.nLen;
        NSUInteger left = lenght - PacketHeadSize;
        NSUInteger start = 0;
        NSLog(@"wxq left = %lu type = %d length = %lu", left, header.type, bodyLength);
        
        //版本异常，说明buffer接收到的数据异常，将buffer清空后重连
        if (version > 10 || version <= 0) {
            [self.buffer setLength:0];
            exit(0);
            return;
        }
        
        while (left >= bodyLength) {
            start += PacketHeadSize;
            NSData* subData = [[self.buffer subdataWithRange:NSMakeRange(start, bodyLength)] copy];
            NSLog(@"wxq 处理从%lu开始长度为%lu的数据", start, bodyLength);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                LSDoTaskCommand* command = [[LSDoTaskCommand alloc] initWithData:subData];
                [command runCommand];
            });
            start += bodyLength;
            left = lenght - start;
            NSLog(@"wxq left = %d start = %d", left, start);
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
            self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(heartbeatPackage:) userInfo:nil repeats:YES];
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
    int state = [[sock userData] intValue];
    NSLog(@"wxq socket丢失连接 state = %d error=%@", state, err);
    //服务器掉线重连
//    if (state == SOCKET_OFFLINE_BY_SERVER) {
//        [self connectServer];
//    }
}

@end
