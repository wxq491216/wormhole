// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>
#import "PlayerDataItem.h"
#import "QYPluginPlayerManager.h"

%hook PumaPlayerViewController

- (id)init
{
    id player = %orig;
    [[QYPluginPlayerManager sharedManager] updatePlayer:player];
    NSLog(@"wxq PumaPlayerViewController init");
    return player;
}

- (void)setCurrentRes:(id)arg1
{
    NSLog(@"wxq PumaPlayerViewController setCurrentRes res = %@", arg1);
    %orig;
}

%end

%hook IOSMctoPlayer

+ (id)GetMctoPlayerInfo:(id)arg1
{
    id info = %orig;
    NSLog(@"wxq IOSMctoPlayer %@ %@", NSStringFromSelector(_cmd), info);
    return info;
}

- (void)Pause
{
    NSLog(@"wxq %@ %@", self, NSStringFromSelector(_cmd));
    %orig;
}

%end


%hook QYAVPlayerController

- (void)updateResByPlayContent
{
    NSLog(@"wxq %@ %@", self, NSStringFromSelector(_cmd));
    %orig;
}

- (void)requestCurrentPlayData:(id)arg1
{
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    %orig;
}

%end

%hook QYPhonePlayerController

- (void)openPlayerByData:(id)arg1
{
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    %orig;
}

%end

%hook QYPhonePlayerControllerCenter

- (void)openPlayerByData:(id)arg1
{
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    %orig;
}

%end

%hook QYPlayerViewController

- (void)playerViewControl:(int)arg1 object:(id)arg2
{
    NSLog(@"wxq %@ %@ arg1 = %@ object = %@", self, NSStringFromSelector(_cmd), arg1, arg2);
    %orig;
}

- (void)doBackBtn
{
    NSLog(@"wxq %@ %@", self, NSStringFromSelector(_cmd));
    %orig;
}

- (void)viewDidLoad
{
    [[QYPluginPlayerManager sharedManager] updatePlayerVC:self];
    %orig;
}

%end

%hook AppDelegate

- (void)openPlayerByData:(id)arg1
{
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    PlayerDataItem* item = (PlayerDataItem*)arg1;
    NSString* albumId = [item albumId];
    NSString* tvId = [item tvId];
    NSString* ctype = [item ctype];
    NSString* pc = [item pc];
    NSString* videoType = [item video_type];
    NSString* sourceId = [item sourceid];
    NSLog(@"wxq albumId =%@ tvId = %@ ctype = %@ pc = %@ videoType = %@ sourceId = %@", albumId, tvId, ctype, pc, videoType, sourceId);
    [[QYPluginPlayerManager sharedManager] updatePlayerItem:item];
    %orig;
}

%end



























