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
    //_pushConfigVC = [[AlivcLivePushConfigViewController alloc] init];
   // _publisherVC = [[AlivcLivePusherViewController alloc] init];
}

- (void)init:(CDVInvokedUrlCommand*)command
{
    dispatch_async(dispatch_get_main_queue(), ^{
      
        
        
        // If a popover is already open, close it; we only want one at a time.
        if (self.publisherVC != nil) {
             
            [self.publisherVC dismissViewControllerAnimated:YES completion:nil];
            self.publisherVC = nil;
        }
      
        
        if(self.publisherVC == nil){
            self.publisherVC = [[AlivcLivePusherViewController alloc] init];
        }

    CDVPluginResult* pluginResult = nil;
    NSString* push_url =  [command.arguments objectAtIndex:0];

    if (push_url == nil || [push_url length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
     
    
    self.pushConfig = [[AlivcLivePushConfig alloc] init];
    self.pushConfig.resolution = AlivcLivePushResolution540P;//默认为540P，最大支持720P
    self.pushConfig.fps = AlivcLivePushFPS20; //建议用户使用20fps
    self.pushConfig.enableAutoBitrate = true; // 打开码率自适应，默认为true
    self.pushConfig.videoEncodeGop = AlivcLivePushVideoEncodeGOP_2;//默认值为2，关键帧间隔越大，延时越高。建议设置为1-2。
    self.pushConfig.connectRetryInterval = 2000; // 单位为毫秒，重连时长2s，重连间隔设置不小于1秒，建议使用默认值即可。
    self.pushConfig.previewMirror = false; // 默认为false，正常情况下都选择false即可。
    self.pushConfig.orientation = AlivcLivePushOrientationPortrait; // 默认为竖屏，可设置home键向左或向右横屏。
    self.pushConfig.enableAutoResolution = YES; //分辨率自适应
  
    
        self.publisherVC.pushURL = push_url;// @"rtmp://rtmp.huayustech.com/kk568/lkiu?auth_key=1652783701-0-0-409541ae4ca292e997fc56166cba15b5";
        self.publisherVC.pushConfig = self.pushConfig;
        self.publisherVC.beautyOn = false;
        self.publisherVC.isUseAsyncInterface = false;
        self.publisherVC.authKey = nil;
        self.publisherVC.authDuration = nil;
        self.publisherVC.isUserMainStream = false;
        self.publisherVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // [self.viewController presentViewController:self.publisherVC animated:YES completion:^{
    //     //[self.publisherVC dismissViewControllerAnimated:YES completion:nil];
    // }];

    // 插件 view 置顶 & 透明
    [self.viewController addChildViewController:self.publisherVC];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];

    [self.webView.superview addSubview:self.publisherVC.view];
    [self.webView.superview bringSubviewToFront:self.webView];
    
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"sucess"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    });
}

@end
