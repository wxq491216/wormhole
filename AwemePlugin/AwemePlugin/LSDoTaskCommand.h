//
//  LSCallFunctionCommand.h
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import <Foundation/Foundation.h>

@interface LSDoTaskCommand : NSObject

-(instancetype)initWithData:(NSData*)data;

-(void)runCommand;

@end
