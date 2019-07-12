//
//  LSDeviceServer.h
//  LSWormhole
//  主要功能是在daemon程序中创建一个socket服务器，用于与本地应用通信，
//  将远程服务器的指令发送到本地应用，以及将本地应用计算的结果转发给远程服务器
//  Created by xqwang on 2018/9/24.
//

#import <Foundation/Foundation.h>
#import "LSSocketHeader.h"

@interface LSDeviceServer : NSObject

@property(nonatomic, assign)id<LSSocketDelegate> delegate;

-(instancetype)initWithPort:(NSUInteger)port;

//开启服务
-(void)startServer;

-(void)sendData:(NSData*)data;

@end
