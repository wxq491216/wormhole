//
//  TTRobotAppCompleteResponse.m
//  LSWormhole
//
//  Created by xqwang on 2019/6/25.
//

#import "TTRobotAppCompleteResponse.h"
#import "TTRobotContext.h"



@implementation TTRobotAppCompleteResponse

-(void)parserResponseData:(NSDictionary *)info
{
    _succ = [[info valueForKey:@"success"] boolValue];
}

@end
