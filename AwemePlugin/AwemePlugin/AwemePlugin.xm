// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import "LSNetworkManager.h"
#import "IESAntiSpam.h"



%hook AppDelegate

- (BOOL)application:(id)application didFinishLaunchingWithOptions:(id)options
{
    BOOL result = %orig;
    [[LSNetworkManager sharedManager] connectServer];
    return result;
}

%end



