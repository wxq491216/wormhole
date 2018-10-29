//
//  LSServerCommand.h
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import <Foundation/Foundation.h>

@interface LSServerCommand : NSObject

@property(nonatomic, strong, readonly)NSString* commandName;

-(instancetype)initWithName:(NSString*)name data:(id)data;

/*****************************
 ******************************
 *********解析命令参数**********
 ******************************
 ******************************/
-(void)parserCommandData:(id)data;

/*****************************
******************************
***********执行命令************
******************************
******************************/
-(void)runCommand;

@end
