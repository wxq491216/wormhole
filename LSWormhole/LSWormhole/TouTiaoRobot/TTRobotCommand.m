//
//  TTRobotCommand.m
//  LSWormhole
//
//  Created by xqwang on 2019/6/24.
//

#import "TTRobotCommand.h"
#import "LSDataFlowManager.h"
#import "TTRobotContext.h"

@interface TTRobotCommand ()

@property(nonatomic, strong)NSString* appName;

@end


@implementation TTRobotCommand

-(void)parserCommandData:(NSDictionary *)info
{
    self.appName = [info valueForKey:@"bundleId"];
}

-(NSDictionary*)responseInfo
{
    return @{
             @"ToutiaoSimulationDevice" : @"TTRobotAppCompleteResponse"
             };
}

-(void)runCommand:(CommandRunComplete)block
{
    NSLog(@"wxq TTRobotCommand开始运行");
    TTRobotContext* context = [[TTRobotContext alloc] initWithBundleId:self.appName];
    [[LSDataFlowManager sharedManager] setContext:context];
    [context go];
//    TTOperation* operation = [[TTOperation alloc] initWithAppName:self.appName];
//    [operation setOperationName:@"ToutiaoSimulationDevice"];
//    TTRobotContext* context = [TTRobotContext sharedContext];
//    [context addOperation:operation];
}

@end
