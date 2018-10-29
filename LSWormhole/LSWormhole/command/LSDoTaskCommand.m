//
//  LSCallFunctionCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import "LSDoTaskCommand.h"

@interface LSDoTaskCommand ()

@property(nonatomic, strong)NSString* taskName;
@property(nonatomic, strong)NSArray* params;

@end

@implementation LSDoTaskCommand

-(void)parserCommandData:(id)data
{
    self.taskName = [data valueForKey:@"name"];
    self.params = [data valueForKey:@"params"];
}

-(void)runCommand
{
    
}

@end
