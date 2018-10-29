//
//  QYPluginPlayerManager.h
//  iQiYiPlugin
//
//  Created by xqwang on 2018/10/10.
//

#import <Foundation/Foundation.h>
#import "PumaPlayerViewController.h"
#import "PlayerDataItem.h"
#import "LSDoTaskCommand.h"

@interface QYPluginPlayerManager : NSObject

+(instancetype)sharedManager;

-(void)updatePlayer:(PumaPlayerViewController*)player;

-(void)updatePlayerItem:(PlayerDataItem*)item;

-(void)updatePlayerVC:(id)playerVC;

-(void)prepareMovie:(NSString*)videoId albumId:(NSString*)albumId;

-(NSDictionary*)getMovieInfo;

-(void)goBack;

-(void)addTask:(LSDoTaskCommand*)task;

@end
