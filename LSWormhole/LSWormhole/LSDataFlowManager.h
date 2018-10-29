//
//  LSDataFlowManager.h
//  LSWormhole
//
//  Created by xqwang on 2018/9/24.
//

#import <Foundation/Foundation.h>

@interface LSDataFlowManager : NSObject

+(instancetype)sharedManager;

-(void)start;

-(void)updatePhoneName:(NSString*)name targetApp:(NSString*)app;

@end
