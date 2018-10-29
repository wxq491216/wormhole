#line 1 "/Users/xqwang/Documents/Theos/iqiyi/iQiYiPlugin/iQiYiPlugin/iQiYiPlugin.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>
#import "PlayerDataItem.h"
#import "QYPluginPlayerManager.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class IOSMctoPlayer; @class AppDelegate; @class PumaPlayerViewController; @class QYAVPlayerController; @class QYPlayerViewController; @class QYPhonePlayerControllerCenter; @class QYPhonePlayerController; 
static PumaPlayerViewController* (*_logos_orig$_ungrouped$PumaPlayerViewController$init)(_LOGOS_SELF_TYPE_INIT PumaPlayerViewController*, SEL) _LOGOS_RETURN_RETAINED; static PumaPlayerViewController* _logos_method$_ungrouped$PumaPlayerViewController$init(_LOGOS_SELF_TYPE_INIT PumaPlayerViewController*, SEL) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$PumaPlayerViewController$setCurrentRes$)(_LOGOS_SELF_TYPE_NORMAL PumaPlayerViewController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$PumaPlayerViewController$setCurrentRes$(_LOGOS_SELF_TYPE_NORMAL PumaPlayerViewController* _LOGOS_SELF_CONST, SEL, id); static id (*_logos_meta_orig$_ungrouped$IOSMctoPlayer$GetMctoPlayerInfo$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id); static id _logos_meta_method$_ungrouped$IOSMctoPlayer$GetMctoPlayerInfo$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$IOSMctoPlayer$Pause)(_LOGOS_SELF_TYPE_NORMAL IOSMctoPlayer* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$IOSMctoPlayer$Pause(_LOGOS_SELF_TYPE_NORMAL IOSMctoPlayer* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$QYAVPlayerController$updateResByPlayContent)(_LOGOS_SELF_TYPE_NORMAL QYAVPlayerController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$QYAVPlayerController$updateResByPlayContent(_LOGOS_SELF_TYPE_NORMAL QYAVPlayerController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$QYAVPlayerController$requestCurrentPlayData$)(_LOGOS_SELF_TYPE_NORMAL QYAVPlayerController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$QYAVPlayerController$requestCurrentPlayData$(_LOGOS_SELF_TYPE_NORMAL QYAVPlayerController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$QYPhonePlayerController$openPlayerByData$)(_LOGOS_SELF_TYPE_NORMAL QYPhonePlayerController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$QYPhonePlayerController$openPlayerByData$(_LOGOS_SELF_TYPE_NORMAL QYPhonePlayerController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$QYPhonePlayerControllerCenter$openPlayerByData$)(_LOGOS_SELF_TYPE_NORMAL QYPhonePlayerControllerCenter* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$QYPhonePlayerControllerCenter$openPlayerByData$(_LOGOS_SELF_TYPE_NORMAL QYPhonePlayerControllerCenter* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$QYPlayerViewController$playerViewControl$object$)(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST, SEL, int, id); static void _logos_method$_ungrouped$QYPlayerViewController$playerViewControl$object$(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST, SEL, int, id); static void (*_logos_orig$_ungrouped$QYPlayerViewController$doBackBtn)(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$QYPlayerViewController$doBackBtn(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$QYPlayerViewController$viewDidLoad)(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$QYPlayerViewController$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$AppDelegate$openPlayerByData$)(_LOGOS_SELF_TYPE_NORMAL AppDelegate* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$AppDelegate$openPlayerByData$(_LOGOS_SELF_TYPE_NORMAL AppDelegate* _LOGOS_SELF_CONST, SEL, id); 

#line 11 "/Users/xqwang/Documents/Theos/iqiyi/iQiYiPlugin/iQiYiPlugin/iQiYiPlugin.xm"



static PumaPlayerViewController* _logos_method$_ungrouped$PumaPlayerViewController$init(_LOGOS_SELF_TYPE_INIT PumaPlayerViewController* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    id player = _logos_orig$_ungrouped$PumaPlayerViewController$init(self, _cmd);
    [[QYPluginPlayerManager sharedManager] updatePlayer:player];
    NSLog(@"wxq PumaPlayerViewController init");
    return player;
}


static void _logos_method$_ungrouped$PumaPlayerViewController$setCurrentRes$(_LOGOS_SELF_TYPE_NORMAL PumaPlayerViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    NSLog(@"wxq PumaPlayerViewController setCurrentRes res = %@", arg1);
    _logos_orig$_ungrouped$PumaPlayerViewController$setCurrentRes$(self, _cmd, arg1);
}






static id _logos_meta_method$_ungrouped$IOSMctoPlayer$GetMctoPlayerInfo$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    id info = _logos_meta_orig$_ungrouped$IOSMctoPlayer$GetMctoPlayerInfo$(self, _cmd, arg1);
    NSLog(@"wxq IOSMctoPlayer %@ %@", NSStringFromSelector(_cmd), info);
    return info;
}


static void _logos_method$_ungrouped$IOSMctoPlayer$Pause(_LOGOS_SELF_TYPE_NORMAL IOSMctoPlayer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    NSLog(@"wxq %@ %@", self, NSStringFromSelector(_cmd));
    _logos_orig$_ungrouped$IOSMctoPlayer$Pause(self, _cmd);
}







static void _logos_method$_ungrouped$QYAVPlayerController$updateResByPlayContent(_LOGOS_SELF_TYPE_NORMAL QYAVPlayerController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    NSLog(@"wxq %@ %@", self, NSStringFromSelector(_cmd));
    _logos_orig$_ungrouped$QYAVPlayerController$updateResByPlayContent(self, _cmd);
}


static void _logos_method$_ungrouped$QYAVPlayerController$requestCurrentPlayData$(_LOGOS_SELF_TYPE_NORMAL QYAVPlayerController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    _logos_orig$_ungrouped$QYAVPlayerController$requestCurrentPlayData$(self, _cmd, arg1);
}






static void _logos_method$_ungrouped$QYPhonePlayerController$openPlayerByData$(_LOGOS_SELF_TYPE_NORMAL QYPhonePlayerController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    _logos_orig$_ungrouped$QYPhonePlayerController$openPlayerByData$(self, _cmd, arg1);
}






static void _logos_method$_ungrouped$QYPhonePlayerControllerCenter$openPlayerByData$(_LOGOS_SELF_TYPE_NORMAL QYPhonePlayerControllerCenter* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    NSLog(@"wxq %@ %@ arg1 = %@", self, NSStringFromSelector(_cmd), arg1);
    _logos_orig$_ungrouped$QYPhonePlayerControllerCenter$openPlayerByData$(self, _cmd, arg1);
}






static void _logos_method$_ungrouped$QYPlayerViewController$playerViewControl$object$(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, int arg1, id arg2) {
    NSLog(@"wxq %@ %@ arg1 = %@ object = %@", self, NSStringFromSelector(_cmd), arg1, arg2);
    _logos_orig$_ungrouped$QYPlayerViewController$playerViewControl$object$(self, _cmd, arg1, arg2);
}


static void _logos_method$_ungrouped$QYPlayerViewController$doBackBtn(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    NSLog(@"wxq %@ %@", self, NSStringFromSelector(_cmd));
    _logos_orig$_ungrouped$QYPlayerViewController$doBackBtn(self, _cmd);
}


static void _logos_method$_ungrouped$QYPlayerViewController$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL QYPlayerViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    [[QYPluginPlayerManager sharedManager] updatePlayerVC:self];
    _logos_orig$_ungrouped$QYPlayerViewController$viewDidLoad(self, _cmd);
}






static void _logos_method$_ungrouped$AppDelegate$openPlayerByData$(_LOGOS_SELF_TYPE_NORMAL AppDelegate* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
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
    _logos_orig$_ungrouped$AppDelegate$openPlayerByData$(self, _cmd, arg1);
}





























static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$PumaPlayerViewController = objc_getClass("PumaPlayerViewController"); MSHookMessageEx(_logos_class$_ungrouped$PumaPlayerViewController, @selector(init), (IMP)&_logos_method$_ungrouped$PumaPlayerViewController$init, (IMP*)&_logos_orig$_ungrouped$PumaPlayerViewController$init);MSHookMessageEx(_logos_class$_ungrouped$PumaPlayerViewController, @selector(setCurrentRes:), (IMP)&_logos_method$_ungrouped$PumaPlayerViewController$setCurrentRes$, (IMP*)&_logos_orig$_ungrouped$PumaPlayerViewController$setCurrentRes$);Class _logos_class$_ungrouped$IOSMctoPlayer = objc_getClass("IOSMctoPlayer"); Class _logos_metaclass$_ungrouped$IOSMctoPlayer = object_getClass(_logos_class$_ungrouped$IOSMctoPlayer); MSHookMessageEx(_logos_metaclass$_ungrouped$IOSMctoPlayer, @selector(GetMctoPlayerInfo:), (IMP)&_logos_meta_method$_ungrouped$IOSMctoPlayer$GetMctoPlayerInfo$, (IMP*)&_logos_meta_orig$_ungrouped$IOSMctoPlayer$GetMctoPlayerInfo$);MSHookMessageEx(_logos_class$_ungrouped$IOSMctoPlayer, @selector(Pause), (IMP)&_logos_method$_ungrouped$IOSMctoPlayer$Pause, (IMP*)&_logos_orig$_ungrouped$IOSMctoPlayer$Pause);Class _logos_class$_ungrouped$QYAVPlayerController = objc_getClass("QYAVPlayerController"); MSHookMessageEx(_logos_class$_ungrouped$QYAVPlayerController, @selector(updateResByPlayContent), (IMP)&_logos_method$_ungrouped$QYAVPlayerController$updateResByPlayContent, (IMP*)&_logos_orig$_ungrouped$QYAVPlayerController$updateResByPlayContent);MSHookMessageEx(_logos_class$_ungrouped$QYAVPlayerController, @selector(requestCurrentPlayData:), (IMP)&_logos_method$_ungrouped$QYAVPlayerController$requestCurrentPlayData$, (IMP*)&_logos_orig$_ungrouped$QYAVPlayerController$requestCurrentPlayData$);Class _logos_class$_ungrouped$QYPhonePlayerController = objc_getClass("QYPhonePlayerController"); MSHookMessageEx(_logos_class$_ungrouped$QYPhonePlayerController, @selector(openPlayerByData:), (IMP)&_logos_method$_ungrouped$QYPhonePlayerController$openPlayerByData$, (IMP*)&_logos_orig$_ungrouped$QYPhonePlayerController$openPlayerByData$);Class _logos_class$_ungrouped$QYPhonePlayerControllerCenter = objc_getClass("QYPhonePlayerControllerCenter"); MSHookMessageEx(_logos_class$_ungrouped$QYPhonePlayerControllerCenter, @selector(openPlayerByData:), (IMP)&_logos_method$_ungrouped$QYPhonePlayerControllerCenter$openPlayerByData$, (IMP*)&_logos_orig$_ungrouped$QYPhonePlayerControllerCenter$openPlayerByData$);Class _logos_class$_ungrouped$QYPlayerViewController = objc_getClass("QYPlayerViewController"); MSHookMessageEx(_logos_class$_ungrouped$QYPlayerViewController, @selector(playerViewControl:object:), (IMP)&_logos_method$_ungrouped$QYPlayerViewController$playerViewControl$object$, (IMP*)&_logos_orig$_ungrouped$QYPlayerViewController$playerViewControl$object$);MSHookMessageEx(_logos_class$_ungrouped$QYPlayerViewController, @selector(doBackBtn), (IMP)&_logos_method$_ungrouped$QYPlayerViewController$doBackBtn, (IMP*)&_logos_orig$_ungrouped$QYPlayerViewController$doBackBtn);MSHookMessageEx(_logos_class$_ungrouped$QYPlayerViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$QYPlayerViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$QYPlayerViewController$viewDidLoad);Class _logos_class$_ungrouped$AppDelegate = objc_getClass("AppDelegate"); MSHookMessageEx(_logos_class$_ungrouped$AppDelegate, @selector(openPlayerByData:), (IMP)&_logos_method$_ungrouped$AppDelegate$openPlayerByData$, (IMP*)&_logos_orig$_ungrouped$AppDelegate$openPlayerByData$);} }
#line 150 "/Users/xqwang/Documents/Theos/iqiyi/iQiYiPlugin/iQiYiPlugin/iQiYiPlugin.xm"
