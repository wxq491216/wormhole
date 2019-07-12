//
//  LSCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/10/7.
//

#import "LSCommand.h"
#import "LSDataFlowManager.h"

@interface LSCommand ()

@end

@implementation LSCommand

-(instancetype)initWithName:(NSString *)name info:(id)info
{
    if (self = [super init]) {
        _commandName = name;;
        [self parserCommandData:info];
        NSDictionary* responseInfo = [self responseInfo];
        [responseInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString* responseName = (NSString*)key;
            NSString* handleClassName = (NSString*)obj;
            [[LSDataFlowManager sharedManager] registerResponse:responseName handleClassName:handleClassName];
        }];
    }
    return self;
}

-(void)parserCommandData:(NSDictionary *)info
{
    NSLog(@"parser %@ command with info %@", self.commandName, info);
}

-(NSDictionary*)responseInfo
{
    return nil;
}

-(void)runCommand:(CommandRunComplete)block
{
    NSLog(@"run %@ command", self.commandName);
    if (block) {
        block(YES, nil);
    }
}

@end
