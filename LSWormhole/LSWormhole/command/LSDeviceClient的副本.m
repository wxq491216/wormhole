//
//  LSNetworkManager.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/18.
//

#import "LSDeviceClient.h"
#import "GCDAsyncSocket.h"
//#import "LSCommandFactory.h"

#define ID_HEART_BEAT_PACKAGE          0
#define ID_NORMAL_PACKAGE              1

#define SOCKET_OFFLINE_BY_SERVER    0
#define SOCKET_OFFLINE_BY_USER      1
#define SOCKET_OFFLINE_BY_NETWORK   2

// 包头
typedef struct tagNetPacketHead
{
    int version;                    //版本
    int type;                       //包体类型
    unsigned int nLen;              //包体长度
} NetPacketHead;

// 定义发包类型
typedef struct tagNetPacket
{
    NetPacketHead header;      //包头
    unsigned char *body;      //包体
} NetPacket;

#define PacketHeadSize          12

@interface LSDeviceClient () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket* socket;
@property(nonatomic, strong)NSTimer* heartTimer;
@property(nonatomic, strong)NSMutableData* buffer;

@property(nonatomic, assign)NSUInteger writeTag;

@end

@implementation LSDeviceClient

//+(instancetype)sharedInstance
//{
//    static LSNetworkManager* instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[LSNetworkManager alloc] init];
//    });
//    return instance;
//}

-(instancetype)init
{
    if (self = [super init]) {
        self.socket = [[GCDAsyncSocket alloc] init];
        [self.socket setDelegate:self];
        self.buffer = [NSMutableData data];
        self.writeTag = 0;
    }
    return self;
}

-(BOOL)connectServer
{
    BOOL succ;
    if (self.socket) {
        NSError* error = nil;
        NSURL* url = [NSURL URLWithString:@""];
        succ = [self.socket connectToUrl:url withTimeout:60.0f error:&error];
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

-(void)sendData:(NSData*)data
{
    struct tagNetPacketHead head;
    head.version = 1;
    head.type = ID_NORMAL_PACKAGE;
    head.nLen = (unsigned int)[data length];
    NSMutableData* packageData = [NSMutableData dataWithBytes:&head length:PacketHeadSize];
    [packageData appendData:data];
    [self.socket writeData:packageData withTimeout:-1 tag:self.writeTag];
    NSLog(@"发送到服务端%ld号数据", self.writeTag++);
}

//心跳
-(void)heartbeatPackage
{
    struct tagNetPacketHead head;
    head.version = 1;
    head.type = ID_HEART_BEAT_PACKAGE;
    head.nLen = 0;
    NSData* heartBeatData = [NSData dataWithBytes:&head length:PacketHeadSize];
    [self.socket writeData:heartBeatData withTimeout:-1 tag:-1];
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
        NSUInteger lenght = [data length];
        NSUInteger bodyLength = header.nLen;
        NSUInteger left = lenght - PacketHeadSize;
        NSUInteger start = 0;
        while (left >= bodyLength) {
            start += PacketHeadSize;
            NSData* subData = [[self.buffer subdataWithRange:NSMakeRange(start, bodyLength)] copy];
            if (self.delegate) {
                id command = [LSCommandFactory createCommand:subData];
                [self.delegate receiveServerCommand:command];
            }
            start += bodyLength;
            left = lenght - start;
            if (left <= PacketHeadSize) {
                break;
            }
            [data getBytes:&header range:NSMakeRange(start, PacketHeadSize)];
            left = lenght - start - PacketHeadSize;
            bodyLength = header.nLen;
        }
        [self.buffer replaceBytesInRange:NSMakeRange(0, start) withBytes:NULL];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url
{
    NSLog(@"socket connected server %@ succ", [url absoluteString]);
    if (self.heartTimer == nil) {
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(heartbeatPackage) userInfo:nil repeats:YES];
    }
    //读数据
    [self.socket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到服务端发送的%ld号数据", tag);
    [self preHandleData:data];
    [self.socket readDataWithTimeout:-1 tag:-1];
}

//-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
//{
//    [self.socket readDataWithTimeout:-1 tag:tag];
//}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    int state = [[sock userData] intValue];
    //服务器掉线重连
    if (state == SOCKET_OFFLINE_BY_SERVER) {
        [self connectServer];
    }
}

@end
