//
//  LSCommandFactory.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import "LSCommandFactory.h"
#import "LSOpenAppCommand.h"

@implementation LSCommandFactory

+(LSCommand*)createCommand:(NSData *)data
{
    id command = nil;
    NSError* error = nil;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSLog(@"wxq 接收到的命令数据为%@", dictionary);
    if (error == nil) {
        NSString* name = [dictionary valueForKey:@"name"];
        NSDictionary* values = [dictionary valueForKey:@"params"];
        if ([name isEqualToString:@"openApp"]) {
            command = [[LSOpenAppCommand alloc] initWithName:name info:values];
        }
    }else{
        NSLog(@"wxq 接收到的服务器数据格式错误，请核查！");
    }
    return command;
}

@end
