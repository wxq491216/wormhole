//
//  LSCommandFactory.h
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import <Foundation/Foundation.h>
#import "LSCommand.h"

@interface LSCommandFactory : NSObject

+(LSCommand*)createCommand:(NSData*)data;

@end
