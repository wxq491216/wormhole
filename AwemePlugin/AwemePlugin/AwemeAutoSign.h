//
//  AwemeAntiTest.h
//  AwemePlugin
//
//  Created by xqwang on 2019/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AwemeAutoSign : NSObject

//通过请求链接、请求体、请求头计算整个请求的签名信息，包括ts/as/mas/x-gorgon等信息
+(NSDictionary*)generalSignature:(NSString*)url body:(NSDictionary*)body header:(NSDictionary*)headerInfo;

+(NSDictionary*)testSignature:(NSString*)inputJson;

@end

NS_ASSUME_NONNULL_END
