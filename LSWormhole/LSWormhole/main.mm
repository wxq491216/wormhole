//
//  main.c
//  LSWormhole
//
//  Created by xqwang on 2018/9/18.
//  Copyright (c) 2018年 ___ORGANIZATIONNAME___. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>
#import "LSDataFlowManager.h"
#import "LSDeviceServer.h"
#import "LSDeviceClient.h"
#import "LSSocketHeader.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool{
        NSLog(@"wxq argc = %d", argc);
        NSString* name = [NSString stringWithUTF8String:argv[1]];
        NSString* app = [NSString stringWithUTF8String:argv[2]];
        NSLog(@"wxq name = %@ app = %@", name, app);
        LSDataFlowManager* manager = [LSDataFlowManager sharedManager];
        [manager updatePhoneName:name targetApp:app];
        [manager start];
        
        CFRunLoopRun();
    }
    return 0;
}

