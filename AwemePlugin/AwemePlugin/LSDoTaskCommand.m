//
//  LSCallFunctionCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import "LSDoTaskCommand.h"
#import "LSNetworkPrefix.h"
#import <objc/runtime.h>
#import "AwemeAutoSign.h"

//@class IESAntiSpam;

@interface LSDoTaskCommand ()

@property(nonatomic, strong)NSString* taskName;
@property(nonatomic, strong)NSMutableDictionary* info;
@property(nonatomic, strong)NSArray* params;

@property(nonatomic, strong)NSString* jobId;

@end

@implementation LSDoTaskCommand

-(instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        NSError* error = nil;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (dictionary && error == nil) {
            self.info = [NSMutableDictionary dictionaryWithDictionary:dictionary];
            self.taskName = [dictionary valueForKey:@"name"];
            self.params = [dictionary valueForKey:@"params"];
            self.jobId = [dictionary valueForKey:@"httpCnswhid"];
            NSLog(@"wxq 创建jobid为%@的任务成功", self.jobId);
        }else{
            NSLog(@"wxq 创建任务失败，JSON数据格式错误");
        }
    }
    return self;
}

-(void)runCommand
{
    NSLog(@"LSDoTaskCommand runCommand with %@", self.params);
    
    if ([self.taskName isEqualToString:@"awemesign"]) {
        NSMutableArray* params = [NSMutableArray array];
        for (NSDictionary* info in self.params) {
            NSLog(@"LSDoTaskCommand runCommand item %@", info);
            
            NSString* link = [info valueForKey:@"link"];
            NSDictionary* body = [info valueForKey:@"body"];
            NSDictionary* head = [info valueForKey:@"head"];
            
            NSMutableDictionary* signedItem = nil;
            NSDictionary* signInfo = [AwemeAutoSign generalSignature:link body:body header:head];
            if (signInfo != nil) {
                NSLog(@"LSDoTaskCommand runCommand signInfo = %@", signInfo);
                signedItem = [NSMutableDictionary dictionaryWithDictionary:info];
                [signedItem setValue:signInfo forKey:@"signature"];
                [params addObject:signedItem];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:self.info];
            [dictionary setValue:params forKey:@"params"];
            [[NSNotificationCenter defaultCenter] postNotificationName:DO_TASK_COMMAND_COMPLETE object:dictionary];
        });
    }
}

@end
