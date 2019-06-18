//
//  LSNetworkManager.h
//  AwemePlugin
//
//  Created by xqwang on 2018/9/25.
//

#import <Foundation/Foundation.h>
#import "LSNetworkPrefix.h"

@interface LSNetworkManager : NSObject

+(instancetype)sharedManager;

-(BOOL)connectServer;

@end
