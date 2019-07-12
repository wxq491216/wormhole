//
//  LSContext.m
//  LSWormhole
//
//  Created by xqwang on 2019/7/11.
//

#import "LSContext.h"

@implementation LSContext

-(instancetype)initWithBundleId:(NSString *)bundleId
{
    if (self = [super init]) {
        _appName = [bundleId copy];
    }
    return self;
}

-(void)go
{
    NSLog(@"wxq LSContext子类需自行实现go接口");
}

-(void)handleResponse:(id)response
{
    NSLog(@"wxq LSContext子类需自行实现handleResponse接口");
}

@end
