/********* LivePlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "AlivcLivePushConfigViewController.h"
#import "AlivcLivePusherViewController.h"
#import <AlivcLivePusher/AlivcLivePusher.h>


@interface LivePlugin : CDVPlugin {
  // Member variables go here.
     
   
}
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;
@property (nonatomic ,strong) AlivcLivePushConfigViewController *pushConfigVC;

@property (nonatomic ,strong) AlivcLivePusherViewController *publisherVC;

- (void)init:(CDVInvokedUrlCommand*)command;
@end

@implementation LivePlugin

- (void)pluginInitialize {
    _pushConfigVC = [[AlivcLivePushConfigViewController alloc] init];
    _publisherVC = [[AlivcLivePusherViewController alloc] init];
}

- (void)init:(CDVInvokedUrlCommand*)command
{
//    AlivcLivePushConfigViewController *_live_config = [[AlivcLivePushConfigViewController alloc] init];
//    _live_config.viewDidLoad();
    
    
  //  AlivcLivePushConfigViewController *pushConfigVC =  [[AlivcLivePushConfigViewController alloc] init];
   // _pushConfigVC.viewDidLoad(@"");
   // [self.pushConfigVC viewDidLoad];
//    self.viewController = _pushConfigVC;
    //[self.viewController.navigationController pushViewController:self.pushConfigVC animated:false];
 
    
    
//    CDVPluginResult* pluginResult = nil;
//    NSString* echo = @"111";// [command.arguments objectAtIndex:0];
//
//    if (echo != nil && [echo length] > 0) {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
//    } else {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//    }
//
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    self.pushConfig = [[AlivcLivePushConfig alloc] init];
    self.pushConfig.resolution = AlivcLivePushResolution540P;//默认为540P，最大支持720P
    self.pushConfig.fps = AlivcLivePushFPS20; //建议用户使用20fps
    self.pushConfig.enableAutoBitrate = true; // 打开码率自适应，默认为true
    self.pushConfig.videoEncodeGop = AlivcLivePushVideoEncodeGOP_2;//默认值为2，关键帧间隔越大，延时越高。建议设置为1-2。
    self.pushConfig.connectRetryInterval = 2000; // 单位为毫秒，重连时长2s，重连间隔设置不小于1秒，建议使用默认值即可。
    self.pushConfig.previewMirror = false; // 默认为false，正常情况下都选择false即可。
    self.pushConfig.orientation = AlivcLivePushOrientationPortrait; // 默认为竖屏，可设置home键向左或向右横屏。
    self.pushConfig.enableAutoResolution = YES; //分辨率自适应
  
    
    _publisherVC.pushURL = @"rtmp://rtmp.huayustech.com/kk568/lkiu?auth_key=1652783701-0-0-409541ae4ca292e997fc56166cba15b5";
    _publisherVC.pushConfig = self.pushConfig;
    _publisherVC.beautyOn = false;// self.beautyOn;
    _publisherVC.isUseAsyncInterface = false;// self.isUseAsync;
    _publisherVC.authKey = nil;// self.authKey;
    _publisherVC.authDuration = nil;// self.authDuration;
    _publisherVC.isUserMainStream = false; //self.isUserMainStream;
    _publisherVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:self.publisherVC animated:YES completion:nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"sucess"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    // Check command.arguments here.
//           [self.commandDelegate runInBackground:^{
//              // [self.viewController.navigationController pushViewController:self.pushConfigVC animated:false];
//               [self.pushConfigVC viewDidLoad];
//
//               NSString* payload = nil;
//               // Some blocking logic...
//               CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
//               // The sendPluginResult method is thread-safe.
//               [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//           }];
}

@end
