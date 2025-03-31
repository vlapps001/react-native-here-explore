#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(NavigationModule, NSObject)

RCT_EXTERN_METHOD(initializeMap:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(startNavigation:(double)startLat 
                  startLng:(double)startLng 
                  destLat:(double)destLat 
                  destLng:(double)destLng)

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end
