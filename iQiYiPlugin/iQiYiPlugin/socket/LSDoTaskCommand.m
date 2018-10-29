//
//  LSCallFunctionCommand.m
//  LSWormhole
//
//  Created by xqwang on 2018/9/23.
//

#import "LSDoTaskCommand.h"
#import "QYPluginPlayerManager.h"
#import "LSNetworkPrefix.h"
#import <objc/runtime.h>


@interface LSDoTaskCommand ()

@property(nonatomic, strong)NSMutableDictionary* info;
@property(nonatomic, strong)NSArray* params;

@property(nonatomic, strong)NSMutableArray* movies;

@property(nonatomic, strong)dispatch_semaphore_t signal;

@end

@implementation LSDoTaskCommand

-(instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        NSError* error = nil;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (dictionary && error == nil) {
            self.info = [NSMutableDictionary dictionaryWithDictionary:dictionary];
            _taskName = [dictionary valueForKey:@"name"];
            self.params = [dictionary valueForKey:@"params"];
            self.movies = [NSMutableArray array];
            self.signal = dispatch_semaphore_create(0);
        }
    }
    return self;
}

-(BOOL)canAsync
{
    if ([self.taskName isEqualToString:@"videoUrl"]) {
        return NO;
    }
    return YES;
}

-(void)updateMovieInfo:(NSDictionary*)movieInfo
{
    @synchronized(self){
        [self.movies addObject:movieInfo];
    }
}

-(void)main
{
    @autoreleasepool{
        NSLog(@"LSDoTaskCommand runCommand with %@", self.params);
        
        if ([self.taskName isEqualToString:@"videoUrl"]) {
            for (NSDictionary* item in self.params) {
                NSLog(@"LSDoTaskCommand runCommand item %@", item);
                NSString* albumId = [item valueForKey:@"albumId"];
                NSString* videoId = [item valueForKey:@"videoId"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[QYPluginPlayerManager sharedManager] prepareMovie:videoId albumId:albumId];
                    NSLog(@"wxq LSDoTaskCommand runCommand:%@ albumId:%@", videoId, albumId);
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self parserMovieInfo:item];
                });
                dispatch_semaphore_wait(self.signal, DISPATCH_TIME_FOREVER);
                NSLog(@"LSDoTaskCommand LSDoTaskCommand runCommand wait signal succ");
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"wxq LSDoTaskCommand LSDoTaskCommand runCommand movies = %@", self.movies);
                NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:self.info];
                [dictionary setValue:self.movies forKey:@"params"];
                [[NSNotificationCenter defaultCenter] postNotificationName:DO_TASK_COMMAND_COMPLETE object:dictionary];
            });
        }
    }
}


-(void)parserMovieInfo:(NSDictionary*)info
{
    NSLog(@"wxq LSDoTaskCommand parserMovie info = %@", info);
    NSDictionary* dictionary = [[QYPluginPlayerManager sharedManager] getMovieInfo];
    NSLog(@"wxq LSDoTaskCommand parserMovie dictionary = %@", dictionary);
    NSMutableArray* movieInfo = [NSMutableArray array];
    NSArray* videoInfo = [dictionary valueForKeyPath:@"data.program.video"];
    NSLog(@"wxq LSDoTaskCommand parserMovie videoInfo = %@", videoInfo);
    for (NSDictionary* videoItem in videoInfo) {
        id fsInfo = [videoItem valueForKey:@"fs"];
        NSLog(@"wxq LSDoTaskCommand parserMovie fsInfo = %@", fsInfo);
        if (fsInfo) {
            for (NSDictionary* fsItem in fsInfo) {
                NSString* fs = [fsItem valueForKey:@"l"];
                fs = [@"http://data.video.iqiyi.com/videos" stringByAppendingPathComponent:fs];
                NSLog(@"wxq LSDoTaskCommand parserMovie fs = %@", fs);
                [movieInfo addObject:fs];
            }
        }
    }
    if ([movieInfo count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self parserMovieUrl:movieInfo movieInfo:info];
        });
    }else{
        dispatch_semaphore_signal(self.signal);
    }
    
}

-(void)parserMovieUrl:(NSMutableArray*)movieUrls movieInfo:(NSDictionary*)info
{
    NSLog(@"wxq LSDoTaskCommand parserMovieUrl movieUrls = %@ movieInfo = %@", movieUrls, info);
    if ([movieUrls count] == 0) {
        return;
    }
    
    NSMutableArray* movieLinks = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString* url in movieUrls) {
        dispatch_group_async(group, queue, ^{
            NSLog(@"wxq LSDoTaskCommand parserMovieUrl url = %@", url);
            NSData* infoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            NSLog(@"wxq LSDoTaskCommand parserMovieUrl infoData = %@", infoData);
            if (infoData != nil) {
                NSDictionary* info = [NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil];
                NSLog(@"wxq LSDoTaskCommand parserMovieUrl info = %@", info);
                NSString* link = [info valueForKey:@"l"];
                NSLog(@"wxq LSDoTaskCommand parserMovieUrl link = %@", info);
                if (link != nil) {
                    [movieLinks addObject:link];
                }
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"wxq LSDoTaskCommand parserMovieUrl goBack");
        [[QYPluginPlayerManager sharedManager] goBack];
    
        NSMutableDictionary* movieInfo = [NSMutableDictionary dictionaryWithDictionary:info];
        [movieInfo setValue:movieLinks forKey:@"movieInfo"];
        [self updateMovieInfo:movieInfo];
        NSLog(@"wxq LSDoTaskCommand parserMovieUrl movieInfo = %@", movieInfo);
        dispatch_semaphore_signal(self.signal);
    });
}

@end
