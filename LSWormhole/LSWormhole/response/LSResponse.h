//
//  LSResponse.h
//  LSWormhole
//
//  Created by xqwang on 2019/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSResponse : NSObject

//response名
@property(nonatomic, retain, readonly)NSString* responseName;

-(instancetype)initWithDictionary:(NSDictionary*)info;

//解析response数据
-(void)parserResponseData:(NSDictionary*)info;

@end

NS_ASSUME_NONNULL_END
