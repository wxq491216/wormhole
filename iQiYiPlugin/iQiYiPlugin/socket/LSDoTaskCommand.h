//
//  LSCallFunctionCommand.h
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import <Foundation/Foundation.h>

@interface LSDoTaskCommand : NSOperation

@property(nonatomic, strong, readonly)NSString* taskName;

-(instancetype)initWithData:(NSData*)data;

-(void)runCommand;

-(BOOL)canAsync;

@end
