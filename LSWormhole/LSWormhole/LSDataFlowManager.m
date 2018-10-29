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

@interface LSDataFlowManager () <LSSocketDelegate>

@property(nonatomic, strong)LSDeviceServer* socketServer;
@property(nonatomic, strong)LSDeviceClient* socketClient;

@property(nonatomic, assign)BOOL running;

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
        self.socketServer = [[LSDeviceServer alloc] initWithPort:22346];
        [self.socketServer setDelegate:self];
        self.socketClient = [[LSDeviceClient alloc] init];
        [self.socketClient setDelegate:self];
    }
    return self;
}

-(void)updatePhoneName:(NSString*)name targetApp:(NSString*)app
{
    [self.socketClient setName:name];
    [self.socketClient setApp:app];
}

-(void)start
{
    if (self.running) {
        return;
    }
    [self.socketClient connectServer];
    [self.socketServer startServer];
}

-(void)socket:(id)sock didReadData:(NSData *)data tag:(long)tag
{
    if ([sock isEqual:self.socketServer]) {
        NSLog(@"wxq 发送数据到远程服务器");
        [self.socketClient sendData:data tag:tag];
    }else if ([sock isEqual:self.socketClient]){
        NSLog(@"wxq 发送数据到应用");
        [self.socketServer sendData:data tag:tag];
    }
}

-(void)appLostConnection
{
    [self.socketClient setAppOpen:NO];
}

@end
