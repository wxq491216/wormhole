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


//@property(nonatomic, assign)BOOL appOpen;

-(BOOL)connectServer;

-(void)sendData:(NSData*)data;

@end
