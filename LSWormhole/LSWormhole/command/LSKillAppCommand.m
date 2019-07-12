//
//  LSKillAppCommand.m
//  LSWormhole
//
//  Created by xqwang on 2019/7/3.
//

#import "LSKillAppCommand.h"
#import "NSTask.h"

@interface LSKillAppCommand ()

@property(nonatomic, strong)NSString* appName;

@end

@implementation LSKillAppCommand

-(void)parserCommandData:(NSDictionary*)info
{
    self.appName = [info valueForKey:@"bundleId"];
}

-(void)runCommand:(CommandRunComplete)block
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];
    NSArray* argument = [NSArray arrayWithObjects:@"-9", "", nil];
    [task setArguments:argument];
    [task launch];
    [task waitUntilExit];
}

@end
