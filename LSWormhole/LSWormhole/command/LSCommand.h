//
//  LSCommand.h
//  LSWormhole
//
//  Created by xqwang on 2018/10/7.
//

#import <Foundation/Foundation.h>
#import "LSSocketHeader.h"

@interface LSCommand : NSObject

@property(nonatomic, readonly, strong)NSString* commandName;

-(instancetype)initWithName:(NSString*)name info:(id)info;

-(void)parserCommandData:(NSDictionary*)info;

//列举command执行过程中需要处理的response信息，responseName为key、处理类字符串为value，用于向注册中心注册
-(NSDictionary*)responseInfo;

-(void)runCommand:(CommandRunComplete)block;

@end
