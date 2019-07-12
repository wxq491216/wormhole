//
//  LSResponse.m
//  LSWormhole
//
//  Created by xqwang on 2019/6/25.
//

#import "LSResponse.h"

@interface LSResponse ()

//发送response的应用
@property(nonatomic, strong)NSString* appName;

@end

@implementation LSResponse

-(instancetype)initWithDictionary:(NSDictionary*)info
{
    if (self = [super init]) {
        _responseName = [info valueForKey:@"name"];
        self.appName = [info valueForKey:@"appName"];
        [self parserResponseData:info];
    }
    return self;
}

-(void)parserResponseData:(NSDictionary *)info
{
    NSLog(@"wxq 请在子类中实现parserResponseData:接口");
}

@end
