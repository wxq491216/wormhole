//
//  LSCommand.h
//  LSWormhole
//
//  Created by xqwang on 2018/10/7.
//

#import <Foundation/Foundation.h>

typedef void(^RunComplete)(BOOL succ, NSData* data);

@interface LSCommand : NSObject

@property(nonatomic, readonly, strong)NSString* commandName;

-(instancetype)initWithName:(NSString*)name info:(id)info;

-(void)parserCommandData:(NSDictionary*)info;

-(void)runCommand:(RunComplete)block;

@end
