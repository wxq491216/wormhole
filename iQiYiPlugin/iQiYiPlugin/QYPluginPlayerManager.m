//
//  QYPluginPlayerManager.m
//  iQiYiPlugin
//
//  Created by xqwang on 2018/10/10.
//

#import "QYPluginPlayerManager.h"
#import "LSNetworkManager.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface QYPluginPlayerManager ()

@property(nonatomic, strong)LSNetworkManager* socket;

@property(nonatomic, strong)PumaPlayerViewController* player;
@property(nonatomic, strong)PlayerDataItem* item;
@property(nonatomic, weak)id playerVC;

@property(nonatomic, strong)NSOperationQueue* syncTaskQueue;
@property(nonatomic, strong)NSOperationQueue* asyncTaskQueue;

@end

@implementation QYPluginPlayerManager

+(instancetype)sharedManager
{
    static QYPluginPlayerManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QYPluginPlayerManager alloc] init];
    });
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.socket = [[LSNetworkManager alloc] init];
        [self.socket connectServer];
        
        self.syncTaskQueue = [[NSOperationQueue alloc] init];
        [self.syncTaskQueue setMaxConcurrentOperationCount:1];
        
        self.asyncTaskQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)updatePlayer:(PumaPlayerViewController*)player
{
    self.player = player;
}

-(void)updatePlayerVC:(id)playerVC
{
    self.playerVC = playerVC;
}

-(void)updatePlayerItem:(PlayerDataItem *)item
{
    self.item = item;
}

-(void)goBack
{
    [self.playerVC performSelector:@selector(playerViewControl:object:) withObject:nil withObject:nil];
}

-(NSDictionary*)getMovieInfo
{
    NSString* info = [self.player getMovieJSON];
    NSError* error = nil;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:[info dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error != nil) {
        return nil;
    }
    return dictionary;
}

-(void)printPlayerInfo
{
    NSString* info = [self.player getMovieJSON];
    NSError* error = nil;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:[info dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (error == nil) {
        NSLog(@"wxq getMovieInfo %@", info);
    }else{
        NSLog(@"wxq parser json info error with %@", error);
    }
}

-(void)prepareMovie:(NSString*)videoId albumId:(NSString*)albumId
{
    if (self.item == nil) {
        Class playerDataItem = NSClassFromString(@"PlayerDataItem");
        self.item = [[playerDataItem alloc] init];
        
        [self.item setSubjectId:@""];
        [self.item setLoadImage:@"ep"];
        [self.item setLoading:@{@"type":@(0), @"img" : @"ep"}];
        [self.item setPc:@"2"];
        [self.item setCtype:@"0"];
    }
    self.item.tvId = videoId;
    self.item.albumId = albumId;
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate openPlayerByData:self.item];
}

-(void)addTask:(LSDoTaskCommand *)task
{
    NSLog(@"wxq addTask %@", task);
    if ([task canAsync]) {
        [self.asyncTaskQueue addOperation:task];
    }else{
        [self.syncTaskQueue addOperation:task];
    }
}

@end
