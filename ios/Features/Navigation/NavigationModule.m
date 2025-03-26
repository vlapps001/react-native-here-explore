#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NavigationModule, NSObject)

RCT_EXTERN_METHOD(
    startNavigation:(NSString *)routeJson
    withSimulation:(BOOL)isSimulated
    withResolver:(RCTPromiseResolveBlock)resolve
    withRejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    stopNavigation:(RCTPromiseResolveBlock)resolve
    withRejecter:(RCTPromiseRejectBlock)reject
)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
