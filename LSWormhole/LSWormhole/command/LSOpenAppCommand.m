//
//  LSOpenAppCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import "LSOpenAppCommand.h"
#import <objc/message.h>

@interface LSOpenAppCommand ()

@property(nonatomic, strong)NSString* appName;

@end

@implementation LSOpenAppCommand

-(void)parserCommandData:(NSDictionary*)info
{
    self.appName = [info valueForKey:@"bundleId"];
}

-(void)runCommand:(CommandRunComplete)block
{
    NSLog(@"wxq 执行打开app命令, %@", self.appName);
    BOOL open = NO;
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    
    BOOL isInstall = [workspace performSelector:@selector(applicationIsInstalled:) withObject:self.appName];
    if (isInstall) {
        //通过bundle id。打开一个APP
        open = [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:self.appName];
    }
    if (block) {
        NSDictionary* info = @{
                               @"name" : @"openApp",
                               @"params" : @{
                                           @"bundleId" : self.appName,
                                           @"result" : @(open)
                                       }
                               };
        NSData* data = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
        block(open, data);
    }
}

@end
