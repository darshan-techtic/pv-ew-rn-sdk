#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PVWebAPIModel, NSObject)

  // Exposing the `getSigningKey` method
  RCT_EXTERN_METHOD(getSigningKey:(NSString *)email callback:(RCTResponseSenderBlock)callback)

  // Exposing the `isBackupActive` method
  RCT_EXTERN_METHOD(isBackupActive:(NSString *)userId orgId:(NSString *)orgId completionHandler:(RCTResponseSenderBlock)completionHandler)
@end
