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
    }
    return self;
}

-(void)startServer
{
    NSLog(@"wxq LSDeviceServer startServer");
    if (self.serverSocket) {
        NSError* error = nil;
        [self.serverSocket acceptOnPort:self.port error:&error];
        NSLog(@"wxq LSDeviceServer startServer acceptOnPort");
        if (error != nil) {
            NSLog(@"%@", error);
        }
    }
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
            bodyLength = header.nLen;
            left = lenght - (start + PacketHeadSize);
            if ((left < bodyLength) && (bodyLength != 0)) {
                break;
            }
            offset = PacketHeadSize + bodyLength;
            if (header.type == ID_NORMAL_PACKAGE) {
                NSData* data = [self.buffer subdataWithRange:NSMakeRange(start, offset)];
                [subData appendData:data];
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

-(void)sendData:(NSData*)data tag:(long)tag
{
    if (self.connectSocket) {
        NSLog(@"wxq 发送%ld号数据到应用", tag);
        [self.connectSocket writeData:data withTimeout:-1 tag:tag];
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
    }else{
        NSLog(@"wxq IOS设备当前仅支持单一客户");
    }
    [self.connectSocket readDataWithTimeout:-1 tag:-1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData* value = [self handleData:data];
    if (self.delegate && value != nil) {
        NSLog(@"wxq 接收到数据包");
        [self.delegate socket:self didReadData:value tag:tag];
    }else{
        NSLog(@"wxq 接收到心跳包 delegate = %@", self.delegate);
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(appLostConnection)]) {
        [self.delegate appLostConnection];
    }
}

@end
