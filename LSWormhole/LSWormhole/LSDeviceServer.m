//
//  LSDeviceServer.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/24.
//

#import "LSDeviceServer.h"
#import "GCDAsyncSocket.h"
#import "LSSocketHeader.h"

@interface LSDeviceServer()<GCDAsyncSocketDelegate>

@property(nonatomic, assign)NSUInteger port;
@property(nonatomic, strong)GCDAsyncSocket* serverSocket;
@property(nonatomic, strong)GCDAsyncSocket* connectSocket;

@property(nonatomic, strong)NSMutableData* buffer;

@property(nonatomic, assign)int tag;
@property(nonatomic, strong)NSObject* lock;

@end

@implementation LSDeviceServer

-(instancetype)initWithPort:(NSUInteger)port
{
    if (self = [super init]) {
        dispatch_queue_t queue = dispatch_queue_create("DeviceServer's queue", DISPATCH_QUEUE_CONCURRENT);
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        [self.serverSocket setAutoDisconnectOnClosedReadStream:NO];
        self.port = port;
        self.buffer = [NSMutableData data];
        self.tag = 0;
        self.lock = [[NSObject alloc] init];
    }
    return self;
}

-(void)startServer
{
    NSLog(@"wxq LSDeviceServer startServer");
    if (self.serverSocket) {
        NSError* error = nil;
        [self.serverSocket acceptOnPort:self.port error:&error];
        NSLog(@"wxq LSDeviceServer startServer acceptOnPort %d", (int)self.port);
        if (error != nil) {
            NSLog(@"%@", error);
        }
    }
}

-(void)handleData:(NSData*)data
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
            bodyLength = header.nLen;
            left = lenght - (start + PacketHeadSize);
            if ((left < bodyLength) && (bodyLength != 0)) {
                break;
            }
            offset = PacketHeadSize + bodyLength;
            NSData* data = [self.buffer subdataWithRange:NSMakeRange(start + PacketHeadSize, bodyLength)];
            
            if (header.type == ID_NORMAL_PACKAGE) {
                //切换大小端
                header.version = CFSwapInt32HostToBig(header.version);
                header.type = CFSwapInt32HostToBig(header.type);
                header.nLen = CFSwapInt32HostToBig(header.nLen);
                [subData appendBytes:&header length:PacketHeadSize];
                [subData appendData:data];
                
                NSDictionary* info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString* packageId = [info valueForKey:@"httpCnswhid"];
                NSLog(@"wxq 接收到应用返回的任务处理数据%@", packageId);
                
            }else if(header.type == ID_RESPONSE_PACKAGE){
                NSLog(@"wxq 接收到应用发送来的反馈包");
                if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveResponse:)]) {
                    [self.delegate socket:self didReceiveResponse:data];
                }
            }else if(header.type == ID_HEART_BEAT_PACKAGE){
                NSLog(@"wxq 接收到应用发送来的心跳包");
            }else if (header.type == ID_COMMAND_PACKAGE){
                NSLog(@"wxq 接收到应用发送的命令包");
                if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveCommand:)]) {
                    [self.delegate socket:self didReceiveCommand:data];
                }
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

-(void)sendData:(NSData*)data
{
    if (self.connectSocket) {
        @synchronized (self.lock) {
            NSLog(@"wxq 发送%d号数据到应用", self.tag);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.connectSocket writeData:data withTimeout:-1 tag:self.tag];
            });
            self.tag++;
        }
        
    }
}

-(void)closeCurrentServer
{
    if (self.connectSocket) {
        [self.connectSocket disconnect];
        self.connectSocket = nil;
    }
}

-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    if (self.connectSocket == nil) {
        self.connectSocket = newSocket;
        NSLog(@"wxq 新socket连接到当前服务");
        if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidConnect:)]) {
            [self.delegate socketDidConnect:self];
        }
    }else{
        NSLog(@"wxq IOS设备当前仅支持单一客户");
    }
    [self.connectSocket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"wxq 接收到数据包");
    [self handleData:data];
    [self.connectSocket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"wxq 向应用发送数据成功");
    [self.connectSocket readDataWithTimeout:-1 tag:-1];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"wxq %@丢失连接 error=%@", self.connectSocket, err);
    self.connectSocket = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didLostConnection:)]) {
        [self.delegate socket:self didLostConnection:err];
    }
}

@end
