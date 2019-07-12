//
//  QQRobotCommand.m
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import "QQRobotCommand.h"
#import "QQRobotContext.h"
#import "LSDataFlowManager.h"

@interface QQRobotCommand ()

@property(nonatomic, strong)NSString* appName;

@end


@implementation QQRobotCommand

-(void)parserCommandData:(NSDictionary *)info
{
    self.appName = [info valueForKey:@"bundleId"];
}

//-(NSDictionary*)responseInfo
//{
//    return @{
//             @"QQRobotAutoScanHeartBeat" : @"QQRobotHeartBeatResponse"
//             };
//}

-(void)runCommand:(CommandRunComplete)block
{
    NSLog(@"wxq QQRobotCommand开始运行");
    QQRobotContext* context = [[QQRobotContext alloc] initWithBundleId:self.appName];
    [[LSDataFlowManager sharedManager] setContext:context];
    [context go];
}

@end
