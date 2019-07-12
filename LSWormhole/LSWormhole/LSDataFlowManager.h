//
//  LSDataFlowManager.h
//  LSWormhole
//
//  Created by xqwang on 2018/9/24.
//

#import <Foundation/Foundation.h>
#import "LSContext.h"

@interface LSDataFlowManager : NSObject

//身份验证标识位
@property(nonatomic, assign, getter=isIdentifyVerify)BOOL identifyVerify;
//正在执行的任务环境对象
@property(nonatomic, strong)LSContext* context;

+(instancetype)sharedManager;

-(void)start;

-(void)updatePhoneName:(NSString*)name targetApp:(NSString*)app;


//构建身份反馈包数据
-(NSData*)createIdentifyData;

//注册处理responseName类
-(void)registerResponse:(NSString*)responseName handleClassName:(NSString*)className;
//取消注册responseName处理类
-(void)unregisterResponse:(NSString*)responseName;

//注册处理名为commandName的Command类
-(void)registerCommand:(NSString*)commandName handleClassName:(NSString*)className;
//取消注册commandName处理类
-(void)unregisterCommand:(NSString*)commandName;

@end
