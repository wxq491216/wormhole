//
//  LSNetworkManager.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/18.
//

#import "LSDeviceClient.h"
#import "GCDAsyncSocket.h"
#import "LSDataFlowManager.h"
#import "LSCommandFactory.h"
#import "LSCommand.h"
#import "LSIdentifyResponse.h"

@interface LSDeviceClient () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket* socket;
@property(nonatomic, strong)NSTimer* heartTimer;
@property(nonatomic, strong)NSMutableData* buffer;

@property(nonatomic, assign)int tag;
@property(nonatomic, strong)NSObject* lock;

@property(nonatomic, assign, getter=isReconnecting)BOOL reconnecting;

@end

@implementation LSDeviceClient

-(instancetype)init
{
    if (self = [super init]) {
        dispatch_queue_t queue = dispatch_queue_create("DeviceClient's queue", DISPATCH_QUEUE_CONCURRENT);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
//        self.identifyVerify = NO;
        self.buffer = [NSMutableData data];
        self.lock = [[NSObject alloc] init];
        self.tag = 0;
    }
    return self;
}

-(BOOL)connectServer
{
    NSLog(@"wxq LSDeviceClient connectServer host = %@ port = %d", SERVER_HOST, SERVER_PORT);
    BOOL succ = YES;
    if (self.socket != nil && ![self.socket isConnected]) {
        NSLog(@"wxq LSDeviceClient connectServer 1");
        @synchronized (self) {
            [self.buffer setLength:0];
        }
        NSError* error = nil;
        succ = [self.socket connectToHost:SERVER_HOST onPort:SERVER_PORT withTimeout:60.0f error:&error];
        NSLog(@"wxq LSDeviceClient connectServer 2");
        if (error != nil) {
            succ = NO;
        }
    }
    return succ;
}

-(void)disconnectSever
{
    if (self.socket) {
        @synchronized (self) {
            [self.buffer setLength:0];
        }
        [self.socket disconnect];
        [self.socket setUserData:@(SOCKET_OFFLINE_BY_USER)];
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
}

//主动与服务断开连接后再次重连连接
-(void)reconnectServer
{
    if (self.isReconnecting) {
        return;
    }
    NSLog(@"wxq 重新连接服务器");
    [self setReconnecting:YES];
    [self.socket setDelegate:nil];
    [self.socket disconnect];
    //清空Buffer
    @synchronized (self) {
        [self.buffer setLength:0];
    }
    
    [self.socket setDelegate:self];
    [self.socket connectToHost:SERVER_HOST onPort:SERVER_PORT withTimeout:60.0f error:nil];
    //计时器检测连接状态，没连接成功时再次尝试连接
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:3 * 60.0f target:self selector:@selector(connectSocket) userInfo:nil repeats:YES];
    });
}

-(void)connectSocket
{
    [self.socket connectToHost:SERVER_HOST onPort:SERVER_PORT withTimeout:60.0f error:nil];
}

-(void)sendData:(NSData*)data
{
    BOOL verify = [[LSDataFlowManager sharedManager] isIdentifyVerify];
    if (!verify) {
        return;
    }
    if(self.socket != nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.socket writeData:data withTimeout:-1 tag:self.tag];
        });
        @synchronized (self.lock) {
            NSLog(@"wxq 发送%d号数据到远程服务器", self.tag);
            self.tag++;
        }
    }
}

//心跳
-(void)heartbeatPackage
{
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_HEART_BEAT_PACKAGE);
    head.nLen = CFSwapInt32(0);
    NSData* heartBeatData = [NSData dataWithBytes:&head length:PacketHeadSize];
    [self.socket writeData:heartBeatData withTimeout:-1 tag:-1];
    NSLog(@"wxq 向远程服务器发送心跳包");
}

//向服务器返回接收到普通数据包的反馈信息
-(void)sendToServerNormalDataResponse:(NSData*)normalData
{
    NSDictionary* info = [NSJSONSerialization JSONObjectWithData:normalData options:0 error:nil];
    NSString* packageId = [info valueForKey:@"httpCnswhid"];
    if ([packageId length] == 0) {
        return;
    }
    NSLog(@"wxq 接收到服务器下发的任务%@", packageId);
    NSDictionary* packetInfo = @{@"httpCnswhid" : packageId};
    NSData* infoData = [NSJSONSerialization dataWithJSONObject:packetInfo options:0 error:nil];
    
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_RESPONSE_PACKAGE);
    head.nLen = CFSwapInt32([infoData length]);
    NSData* headData = [NSData dataWithBytes:&head length:PacketHeadSize];
    NSMutableData* packageData = [NSMutableData dataWithData:headData];
    [packageData appendData:infoData];
    
    [self sendData:packageData];
}

-(void)handleData:(NSData*)data
{
    NSMutableData* subData = [NSMutableData data];
    @synchronized(self){
//        NSLog(@"wxq 接收到数据buffer = %@", self.buffer);
        [self.buffer appendData:data];
//        NSLog(@"wxq 接收到数据buffer = %@", self.buffer);
        struct tagNetPacketHead header;
        NSUInteger lenght = [self.buffer length];
        NSUInteger bodyLength = 0;
        NSUInteger left = 0;
        NSUInteger start = 0;
        NSUInteger offset = 0;
        do{
            if (lenght - start < PacketHeadSize) {
                break;
            }
            [self.buffer getBytes:&header range:NSMakeRange(start, PacketHeadSize)];
            NSLog(@"wxq 接收到数据头0，version = %d type = %d length = %d", header.version, header.type, header.nLen);
            header.version = CFSwapInt32BigToHost(header.version);
            header.type = CFSwapInt32BigToHost(header.type);
            header.nLen = CFSwapInt32BigToHost(header.nLen);
            NSLog(@"wxq 接收到数据头1，version = %d type = %d length = %d", header.version, header.type, header.nLen);
            bodyLength = header.nLen;
            
            //版本号异常，表示数据读取出现混乱，清空buffer后，中断当前连接，重新开始
            if(header.version > 10 || header.version <= 0){
                start = lenght;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self reconnectServer];
                });
                break;
            }
            
            left = lenght - (start + PacketHeadSize);
            NSLog(@"wxq length = %lu left = %lu start = %lu", (unsigned long)lenght, (unsigned long)left, (unsigned long)start);
            if ((left < bodyLength) && (bodyLength != 0)) {
                break;
            }
            
            offset = PacketHeadSize + bodyLength;
            
            if (header.type == ID_NORMAL_PACKAGE) {
                [subData appendBytes:&header length:PacketHeadSize];
                NSData* data = [[self.buffer subdataWithRange:NSMakeRange(start + PacketHeadSize, bodyLength)] copy];
                [subData appendData:data];
                //普通数据包反馈
                [self sendToServerNormalDataResponse:data];
            }else if(header.type == ID_RESPONSE_PACKAGE){
                NSData* data = [self.buffer subdataWithRange:NSMakeRange(start + PacketHeadSize, bodyLength)];
//                NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveResponse:)]) {
                    [self.delegate socket:self didReceiveResponse:data];
                }
//                NSString* type = [dictionary valueForKey:@"name"];
//                NSLog(@"wxq 服务器返回信息：type = %@", type);
//                if ([type isEqualToString:@"identyVerify"]) {
//                    NSString* message = [dictionary valueForKeyPath:@"params.message"];
//                    int code = [[dictionary valueForKeyPath:@"params.code"] intValue];
//                    NSLog(@"wxq 返回身份验证结果：message = %@ code = %d", message, code);
//                    self.identifyVerify = YES;
//                }
            }else if (header.type == ID_COMMAND_PACKAGE){
                NSLog(@"wxq 接收到服务器发送的命令包");
                NSData* data = [self.buffer subdataWithRange:NSMakeRange(start + PacketHeadSize, bodyLength)];
                if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveCommand:)]) {
                    [self.delegate socket:self didReceiveCommand:data];
                }
//                LSCommand* command = [LSCommandFactory createCommand:data];
//                if (command) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        [command runCommand:^(BOOL succ, NSData *data) {
//                            [self sendCommandResponse:data];
//                        }];
//                    });
//                }
            }
            start += offset;
        }while (YES);
        
        [self.buffer replaceBytesInRange:NSMakeRange(0, start) withBytes:NULL length:0];
    }
    if ([subData length] > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveNormalData:)]) {
            [self.delegate socket:self didReceiveNormalData:subData];
        }
    }
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"wxq 成功连接到服务器%@:%d", host, port);
    [self setReconnecting:NO];
    if (self.heartTimer == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(heartbeatPackage) userInfo:nil repeats:YES];
        });
    }
    NSLog(@"wxq 向远程服务器发送身份识别包");
    NSData* data = [[LSDataFlowManager sharedManager] createIdentifyData];
    [self.socket writeData:data withTimeout:-1 tag:self.tag];
    
    //读数据
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //正在重连时接收到的包丢弃
    if (self.isReconnecting) {
        return;
    }
    NSLog(@"wxq 接收到服务端发送的数据");
    [self handleData:data];
//    if (self.delegate && [message length] != 0) {
//        if (!self.appOpen) {
//            [self openAppThanSendData:message];
//        }else{
//            [self.delegate socket:self didReceiveNormalData:message];
//        }
//    }
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"wxq 向服务器发送数据成功");
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (self.heartTimer) {
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
    
    int state = [[sock userData] intValue];
    NSLog(@"wxq socket丢失连接 state = %d", state);
    //服务器掉线10秒后重连
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self reconnectServer];
    });
}

@end
