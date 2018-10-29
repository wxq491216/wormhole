//
//  LSServerCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import "LSServerCommand.h"

@implementation LSServerCommand

-(instancetype)initWithName:(NSString *)name data:(id)data
{
    if (self = [self init]) {
        _commandName = name;
        [self parserCommandData:data];
    }
    return self;
}

-(void)parserCommandData:(id)data
{
    NSAssert(0, @"必须在子类对象中调用此接口");
}

-(void)runCommand
{
    NSAssert(0, @"必须在子类对象中调用此接口");
}

@end
