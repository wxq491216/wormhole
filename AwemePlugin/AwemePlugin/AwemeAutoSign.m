//
//  AwemeAntiTest.m
//  AwemePlugin
//
//  Created by xqwang on 2019/5/15.
//

#import "AwemeAutoSign.h"
#import "IESAntiSpam.h"

@implementation AwemeAutoSign

+(NSDictionary*)generalSignature:(NSString *)url body:(NSDictionary *)body header:(nonnull NSDictionary *)headerInfo
{
    NSLog(@"wxq AwemeAutoSign generalAsMas:generalSignature:body:header: url = %@ body = %@ header = %@", url, body, headerInfo);
    NSMutableDictionary* retInfo = nil;
    if ([url length] == 0) {
        return retInfo;
    }
    
    NSURL* sourceUrl = [NSURL URLWithString:url];
    retInfo = [self generalRequestSecurityHeader:sourceUrl message:headerInfo];
    NSLog(@"wxq retInfo = %@", retInfo);
    return retInfo;
}

+(id)generalAsMas:(NSNumber*)time parameters:(id)info
{
    long long t = [time longLongValue];
    NSLog(@"wxq AwemeAutoSign generalAsMas:parameters: time = %lld params = %@", t, info);
    Class IESAntiSpam = NSClassFromString(@"IESAntiSpam");
    id r = [IESAntiSpam performSelector:@selector(encryptDataWithTimeStamp:parameters:) withObject:time withObject:info];
    
    NSLog(@"wxq AwemeAutoSign AwemeAutoSign generalAsMas:parameters: result = %@", r);
    return r;
}

+(id)generalRequestSecurityHeader:(NSURL*)url message:(NSDictionary*)info
{
    NSLog(@"wxq AwemeAutoSign generalRequestSecurityHeader:message: url = %@ message = %@", url, info);
//    [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        NSLog(@"wxq key = %@ value = %@", key, obj);
//    }];
//    NSString* cookie = [info valueForKey:@"cookie"];
//    NSLog(@"wxq cookie = %@", cookie);
    
    Class IESAntiSpam = NSClassFromString(@"IESAntiSpam");
    id spam = [IESAntiSpam performSelector:@selector(sharedInstance)];
    id ret = [spam performSelector:@selector(testForAlert:msg:) withObject:url withObject:info];
    NSLog(@"wxq AwemeAutoSign generalRequestSecurityHeader:message: result = %@", ret);
    return ret;
}

+(NSDictionary*)testSignature:(NSString *)inputJson
{
    NSError* error = nil;
    NSData* jsonData = [inputJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    NSString* formatUrl = [jsonInfo valueForKey:@"link"];
    
//    NSMutableArray* querys = [NSMutableArray array];
//    NSMutableDictionary* params = [NSMutableDictionary dictionary];
//    NSURLComponents* component = [NSURLComponents componentsWithString:formatUrl];
//    [[component queryItems] enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString* key = [obj name];
//        if (!([key isEqualToString:@"as"] || [key isEqualToString:@"mas"] || [key isEqualToString:@"ts"])) {
//            NSString* value = [[obj value] stringByRemovingPercentEncoding];
//            [params setValue:value forKey:key];
//            [querys addObject:obj];
//            NSLog(@"wxq key=%@ value=%@", key, obj);
//        }
//    }];
//
//    NSDictionary* body = [jsonInfo valueForKey:@"body"];
//    [params addEntriesFromDictionary:body];
//
//    long long interval = (long long)[[NSDate date] timeIntervalSince1970];
//    NSNumber* time = [NSNumber numberWithLongLong:interval];
//    [params setValue:[time description] forKey:@"ts"];
//    NSLog(@"wxq time = %lld params = %@", interval, params);
//    NSDictionary* signatureInfo = [self generalAsMas:time parameters:params];
//    NSLog(@"wxq info = %@", signatureInfo);
//
//    //更新as/mas/ts信息
//    [signatureInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        NSURLQueryItem* item = [[NSURLQueryItem alloc] initWithName:key value:obj];
//        [querys addObject:item];
//    }];
//    [component setQueryItems:querys];
    
    NSMutableDictionary* header = [jsonInfo valueForKey:@"head"];
    NSURL* sourceUrl = [NSURL URLWithString:formatUrl];
    NSLog(@"wxq sourceUrl = %@ header = %@", sourceUrl, header);
    NSDictionary* headerInfo = [self generalRequestSecurityHeader:sourceUrl message:header];
    NSLog(@"wxq headerInfo = %@", headerInfo);
    
//    NSMutableDictionary* retDic = [NSMutableDictionary dictionaryWithDictionary:signatureInfo];
//    [retDic addEntriesFromDictionary:headerInfo];
    return headerInfo;
}

@end
