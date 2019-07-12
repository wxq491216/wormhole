//
//  LSIdentifyResponse.m
//  LSWormhole
//
//  Created by xqwang on 2019/6/25.
//

#import "LSIdentifyResponse.h"
#import "LSDataFlowManager.h"

@interface LSIdentifyResponse ()

@property(nonatomic, strong)NSString* message;
@property(nonatomic, assign)int code;

@end

@implementation LSIdentifyResponse

-(void)parserResponseData:(NSDictionary *)info
{
    self.message = [info valueForKeyPath:@"params.message"];
    self.code = [[info valueForKeyPath:@"params.code"] intValue];
}

-(void)handleResponse
{
    NSLog(@"wxq 返回身份验证结果：message = %@ code = %d", self.message, self.code);
    [[LSDataFlowManager sharedManager] setIdentifyVerify:YES];
}

@end
