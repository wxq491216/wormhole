//
//  LSSocketHeader.h
//  LSWormhole
//  Created by xqwang on 2018/9/24.
//

#import <Foundation/Foundation.h>
#import "LSDoTaskCommand.h"

#define PacketHeadSize          12

#define ID_HEART_BEAT_PACKAGE          0
#define ID_NORMAL_PACKAGE              1

#define SOCKET_OFFLINE_BY_SERVER    0
#define SOCKET_OFFLINE_BY_USER      1
#define SOCKET_OFFLINE_BY_NETWORK   2

#define DO_TASK_COMMAND_COMPLETE    @"DoTaskCommandComplete"

#define LOCAL_SERVER_PORT 22346

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

@protocol LSNetworkDelegate<NSObject>

-(void)receiveServerCommand:(LSDoTaskCommand*)command;

@end


