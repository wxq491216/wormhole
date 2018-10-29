//
//  LSCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/10/7.
//

#import "LSCommand.h"

@interface LSCommand ()

@end

@implementation LSCommand

-(instancetype)initWithName:(NSString *)name info:(id)info
{
    if (self = [super init]) {
        _commandName = name;;
        [self parserCommandData:info];
    }
    return self;
}

-(void)parserCommandData:(NSDictionary *)info
{
    NSLog(@"parser %@ command with info %@", self.commandName, info);
}

-(void)runCommand:(RunComplete)block
{
    NSLog(@"run %@ command", self.commandName);
    if (block) {
        block(YES, nil);
    }
}

@end
