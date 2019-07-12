//
//  QQRobotContext.m
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import "QQRobotContext.h"
#import "QQRobotTask.h"

@interface QQRobotContext ()

@property(nonatomic, strong)QQRobotTask* task;

@end


@implementation QQRobotContext

-(instancetype)initWithBundleId:(NSString*)bundleId
{
    if (self = [super initWithBundleId:bundleId]) {
        self.task = [[QQRobotTask alloc] initWithTargetApp:bundleId];
    }
    return self;
}

-(void)go
{
    [self.task start];
}

@end
