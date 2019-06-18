//
//  LSDeviceClient.h
//  LSWormhole
//  与远程服务器通信Socket类
//  Created by xqwang on 2018/9/18.
//

#import <Foundation/Foundation.h>
#import "LSSocketHeader.h"



@interface LSDeviceClient : NSObject

@property(nonatomic, assign)id<LSSocketDelegate> delegate;

//设备名称
@property(nonatomic, strong)NSString* name;

//设备服务的目标应用
@property(nonatomic, strong)NSString* app;
@property(nonatomic, assign)BOOL appOpen;

-(BOOL)connectServer;

-(void)sendData:(NSData*)data tag:(long)tag;

@end
