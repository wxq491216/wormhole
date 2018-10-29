//
//  LSNetworkManager.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/18.
//

#import "LSDeviceClient.h"
#import "GCDAsyncSocket.h"
#import "LSCommandFactory.h"
#import "LSCommand.h"

@interface LSDeviceClient () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket* socket;
@property(nonatomic, strong)NSTimer* heartTimer;
@property(nonatomic, strong)NSMutableData* buffer;
@property(nonatomic, assign)BOOL identifyVerify;

@end

@implementation LSDeviceClient

-(instancetype)init
{
    if (self = [super init]) {
        dispatch_queue_t queue = dispatch_queue_create("DeviceClient's queue", DISPATCH_QUEUE_CONCURRENT);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        self.identifyVerify = NO;
        self.buffer = [NSMutableData data];
    }
    return self;
}

-(BOOL)connectServer
{
    NSLog(@"wxq LSDeviceClient connectServer host = %@ port = %d", SERVER_HOST, SERVER_PORT);
    BOOL succ = YES;
    if (self.socket != nil) {
        NSLog(@"wxq LSDeviceClient connectServer 1");
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
        [self.socket disconnect];
        [self.socket setUserData:@(SOCKET_OFFLINE_BY_USER)];
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
}

-(void)sendData:(NSData*)data tag:(long)tag
{
    if(self.socket != nil && self.identifyVerify){
        [self.socket writeData:data withTimeout:-1 tag:tag];
        NSLog(@"wxq 发送到服务端%ld号数据", tag);
    }
}

-(void)sendCommandResponse:(NSData*)data
{
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_RESPONSE_PACKAGE);
    head.nLen = CFSwapInt32((unsigned int)[data length]);
    
    NSMutableData* commandData = [NSMutableData data];
    [commandData appendData:[NSData dataWithBytes:&head length:PacketHeadSize]];
    [commandData appendData:data];
    [self.socket writeData:commandData withTimeout:-1 tag:-1];
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

-(void)sendIdentifyPackage
{
    NSDictionary* identifyInfo = @{
                                       @"userName" : self.name,
                                       @"type" : @(1),
                                       @"app" : self.app
                                   };
    NSData* identifyData = [NSJSONSerialization dataWithJSONObject:identifyInfo options:0 error:nil];
    
    struct tagNetPacketHead head;
    head.version = CFSwapInt32(1);
    head.type = CFSwapInt32(ID_IDENTIFY_PACKAGE);
    head.nLen = CFSwapInt32((unsigned int)[identifyData length]);
    NSData* identifyHeadData = [NSData dataWithBytes:&head length:PacketHeadSize];
    
    NSMutableData* data = [NSMutableData dataWithData:identifyHeadData];
    [data appendData:identifyData];
    [self.socket writeData:data withTimeout:-1 tag:-1];
    NSLog(@"wxq 向远程服务器发送身份包");
}

-(void)openAppThanSendData:(NSData*)message
{
    NSDictionary* identifyInfo = @{
                                   @"name" : @"openApp",
                                   @"params" : @{
                                            @"bundleId" : self.app,
                                           }
                                   };
    NSData* data = [NSJSONSerialization dataWithJSONObject:identifyInfo options:0 error:nil];
    LSCommand* command = [LSCommandFactory createCommand:data];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [command runCommand:^(BOOL succ, NSData *data) {
            self.appOpen = YES;
            if (self.delegate) {
                [self.delegate socket:self didReadData:message tag:-1];
            }
        }];
    });
}

-(NSData*)handleData:(NSData*)data
{
    NSMutableData* subData = [NSMutableData data];
    @synchronized(self){
        [self.buffer appendData:data];
        
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
            header.version = CFSwapInt32BigToHost(header.version);
            header.type = CFSwapInt32BigToHost(header.type);
            header.nLen = CFSwapInt32BigToHost(header.nLen);
            NSLog(@"wxq 接收到数据头，version = %d type = %d length = %d", header.version, header.type, header.nLen);
            bodyLength = header.nLen;
            
            left = lenght - (start + PacketHeadSize);
            if ((left < bodyLength) && (bodyLength != 0)) {
                break;
            }
            
            offset = PacketHeadSize + bodyLength;
            NSLog(@"length = %d left = %d start = %d", lenght, left, start);
            if (header.type == ID_NORMAL_PACKAGE) {
                NSData* data = [self.buffer subdataWithRange:NSMakeRange(start, offset)];
                [subData appendData:data];
            }else if(header.type == ID_RESPONSE_PACKAGE){
                NSData* data = [self.buffer subdataWithRange:NSMakeRange(start + PacketHeadSize, bodyLength)];
                NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString* type = [dictionary valueForKey:@"name"];
                NSLog(@"wxq 服务器返回信息：type = %@", type);
                if ([type isEqualToString:@"identyVerify"]) {
                    NSString* message = [dictionary valueForKeyPath:@"params.message"];
                    int code = [[dictionary valueForKeyPath:@"params.code"] intValue];
                    NSLog(@"wxq 返回身份验证结果：message = %@ code = %d", message, code);
                    self.identifyVerify = YES;
                }
            }else if (header.type == ID_COMMAND_PACKAGE){
                NSLog(@"wxq 接收到服务器指令");
                NSData* data = [self.buffer subdataWithRange:NSMakeRange(start + PacketHeadSize, bodyLength)];
                LSCommand* command = [LSCommandFactory createCommand:data];
                if (command) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [command runCommand:^(BOOL succ, NSData *data) {
                            [self sendCommandResponse:data];
                        }];
                    });
                }
            }
            start += offset;
        }while (YES);
        
        [self.buffer replaceBytesInRange:NSMakeRange(0, start) withBytes:NULL length:0];
    }
    if ([subData length] == 0) {
        subData = nil;
    }
    return subData;
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"wxq 成功连接到服务器%@:%d", host, port);
    if (self.heartTimer == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(heartbeatPackage) userInfo:nil repeats:YES];
        });
    }
    [self sendIdentifyPackage];
    //读数据
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"wxq 接收到服务端发送的%ld号数据", tag);
    NSData* message = [self handleData:data];
    if (self.delegate && [message length] != 0) {
        if (!self.appOpen) {
            [self openAppThanSendData:message];
        }else{
            [self.delegate socket:self didReadData:message tag:tag];
        }
    }
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"wxq 服务器发送数据成功");
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"wxq socket丢失连接");
    if (err) {
        NSLog(@"%@", err);
    }
    
    if (self.heartTimer) {
        [self.heartTimer invalidate];
        self.heartTimer = nil;
    }
    
    int state = [[sock userData] intValue];
    //服务器掉线重连
    if (state == SOCKET_OFFLINE_BY_SERVER) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*60*NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self connectServer];
        });
    }
}

@end
