/********* LivePlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "AlivcLivePushConfigViewController.h"
#import "AlivcLivePusherViewController.h"
#import <AlivcLivePusher/AlivcLivePusher.h>
 

@interface LivePlugin : CDVPlugin {
  //   variables go here.
     
   
}
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;
@property (nonatomic ,strong) AlivcLivePushConfigViewController *pushConfigVC;
@property (nonatomic ,strong) AlivcLivePusherViewController *publisherVC;

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)start:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
 
- (void)preview:(CDVInvokedUrlCommand*)command;
- (void)Pause:(CDVInvokedUrlCommand*)command;
- (void)ResumeAsync:(CDVInvokedUrlCommand*)command;
- (void)RestartPushAync:(CDVInvokedUrlCommand*)command;
- (void)StopPreview:(CDVInvokedUrlCommand*)command;

- (void)CameraDirection:(CDVInvokedUrlCommand*)command;
- (void)LiveFlash:(CDVInvokedUrlCommand*)command;


@end

@implementation LivePlugin


static NSString* myAsyncCallBackId = nil;
static CDVPluginResult *pluginResult = nil;
static LivePlugin *selfplugin = nil;

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
        
        //0 推流URL地址
        //1 是否竖屏. 1是竖屏,2横屏朝home键,3横屏朝不朝home键
        //2 是否前置摄像头. 1是
        //3 纯音频
        //4 纯视频
        //5 是否在webview以下. 1 默认是在下方
        //6 窗口宽. -1 默认全屏
        //7 窗口高. -1 默认全屏
        //8 x坐标 默认0
        //9 y坐标 默认0
        NSString* push_url =  [command.arguments objectAtIndex:0];
        NSString* orientation =  [command.arguments objectAtIndex:1];
        NSString* i_cameraType =  [command.arguments objectAtIndex:2];
        NSString* i_audioOnly =  [command.arguments objectAtIndex:3];
        NSString* i_videoOnly =  [command.arguments objectAtIndex:4];

        NSString* i_under =  [command.arguments objectAtIndex:5];
        NSString* i_width =  [command.arguments objectAtIndex:6];
        NSString* i_height =  [command.arguments objectAtIndex:7];
        NSString* i_left =  [command.arguments objectAtIndex:8];
        NSString* i_top =  [command.arguments objectAtIndex:9];


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
    if( [orientation isEqualToString:  @"2" ]){
        self.pushConfig.orientation = AlivcLivePushOrientationLandscapeLeft; // 默认为竖屏，可设置home键向左或向右横屏。
    }
    else if([orientation isEqualToString:@"3"]){
        self.pushConfig.orientation = AlivcLivePushOrientationLandscapeRight; // 默认为竖屏，可设置home键向左或向右横屏。
    }
    self.pushConfig.cameraType = AlivcLivePushCameraTypeBack;
    if([i_cameraType isEqualToString: @"1"]){
        self.pushConfig.cameraType = AlivcLivePushCameraTypeFront;//前置摄像头
    }
    if([i_audioOnly isEqualToString: @"1"]){
        self.pushConfig.audioOnly = true ;
    }
    if([i_videoOnly isEqualToString: @"1"]){
        self.pushConfig.videoOnly = true;
    }
    self.pushConfig.enableAutoResolution = YES; //分辨率自适应
  
    
        self.publisherVC.pushURL = push_url;// @"rtmp://rtmp.huayustech.com/kk568/lkiu?auth_key=1652783701-0-0-409541ae4ca292e997fc56166cba15b5";
        self.publisherVC.pushConfig = self.pushConfig;
        self.publisherVC.beautyOn = false;
        self.publisherVC.isUseAsyncInterface = false;//异步
        self.publisherVC.authKey = nil;
        self.publisherVC.authDuration = nil;
        self.publisherVC.isUserMainStream = false;
        self.publisherVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        self.publisherVC.pushUnder = i_under;
        self.publisherVC.pushWidth = [i_width integerValue];
        self.publisherVC.pushHeight = [i_height integerValue];
        self.publisherVC.pushLeft = [i_left integerValue];
        self.publisherVC.pushTop = [i_top integerValue];
    
    // [self.viewController presentViewController:self.publisherVC animated:YES completion:^{
    //     //[self.publisherVC dismissViewControllerAnimated:YES completion:nil];
    // }];

    // 插件 view 置顶 & 透明
    [self.viewController addChildViewController:self.publisherVC];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];

    [self.webView.superview addSubview:self.publisherVC.view];
    [self.webView.superview bringSubviewToFront:self.webView];
    
    myAsyncCallBackId = command.callbackId;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"sucess"];
    [pluginResult setKeepCallbackAsBool:YES]; //不销毁，保存监听回调
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    });
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    NSString *msg =@"-10|推流未知错误";
    if([self.publisherVC start] != 0){
        msg = @"102|开启推流";
    }
    [self sendCmd: msg];
    
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    [self.publisherVC stop];
    
}

//开启预览
- (void)preview:(CDVInvokedUrlCommand*)command
{
    [self.publisherVC  startPreviewPlugin];
}

//停止预览
- (void)StopPreview:(CDVInvokedUrlCommand *) command{
    [self.publisherVC  StopPreviewPlugin];
}


- (void)Pause:(CDVInvokedUrlCommand *)command 
{
    [self.publisherVC  pausePushPlugin];
}


- (void)ResumeAsync:(CDVInvokedUrlCommand *) command
{
     [self.publisherVC  resumePushPlugin];

}


- (void)RestartPushAync:(CDVInvokedUrlCommand *) command
{
    [self.publisherVC  restartPushPlugin];
}

- (void)CameraDirection:(CDVInvokedUrlCommand*)command{
    [self.publisherVC CameraDirection];
}

- (void)LiveFlash:(CDVInvokedUrlCommand*)command{
    [self.publisherVC LiveFlash];
}

//初始化播放器
- (void)InitPlayer:(CDVInvokedUrlCommand *) command
{   
    //0 播流URL地址
    //1 窗口宽. -1 默认全屏
    //2 窗口高. -1 默认全屏的25%
    //3 x坐标 默认0
    //4 y坐标 默认0

    NSString* play_url =  [command.arguments objectAtIndex:0];   
    NSString* i_width =  [command.arguments objectAtIndex:1];
    NSString* i_height =  [command.arguments objectAtIndex:2];
    NSString* i_left =  [command.arguments objectAtIndex:3];
    NSString* i_top =  [command.arguments objectAtIndex:4];

    self.publisherVC.playUrl = play_url;
    self.publisherVC.playerWidth = [i_width integerValue];
    self.publisherVC.playerHeight = [i_height integerValue];
    self.publisherVC.playerLeft = [i_left integerValue];
    self.publisherVC.playerTop = [i_top integerValue];
    
    [self.publisherVC setupPlayer];
}

//开启播放
- (void)PlayerStart:(CDVInvokedUrlCommand *) command
{
    [self.publisherVC  PlayerStart];
}

//暂停播放
- (void)PlayerPause:(CDVInvokedUrlCommand *) command
{
    [self.publisherVC  PlayerPause];
}

//恢复播放
- (void)PlayerResume:(CDVInvokedUrlCommand *) command
{
    [self.publisherVC  PlayerResume];
}

//停止播放
- (void)PlayerStop:(CDVInvokedUrlCommand *) command
{
    [self.publisherVC  PlayerStop];
}


//播放器截图
- (void)PlayerSnapshot:(CDVInvokedUrlCommand *) command
{
    [self.publisherVC  PlayerSnapshot];
}

//是否静音 1静音
- (void)PlayerIsMute:(CDVInvokedUrlCommand *) command
{
    NSString* play_IsMute =  [command.arguments objectAtIndex:0];
    [self.publisherVC  PlayerIsMute];
}

//设置播放器音量
//arg0 音量大小
- (void)PlayerSetVolume :(CDVInvokedUrlCommand *) command
{
    NSString* play_Volume =  [command.arguments objectAtIndex:0];
    [self.publisherVC  PlayerSetVolume : [play_Volume floatValue] ];
}

 
- (void)PlayerMirrorMode:(CDVInvokedUrlCommand *) command
{
   // [self.publisherVC  PlayerMirrorMode];
}

- (void)PlayerScaleMode:(CDVInvokedUrlCommand *) command
{
   // [self.publisherVC  PlayerScaleMode];
}

- (void)PlayerRotateMode:(CDVInvokedUrlCommand *) command
{
   // [self.publisherVC  PlayerRotateMode];
}


-  (void)  sendCmd : (NSString *)msg
{
    if(myAsyncCallBackId != nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: msg ];
        //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
        [pluginResult  setKeepCallbackAsBool:YES];
        [selfplugin.commandDelegate sendPluginResult:pluginResult callbackId: myAsyncCallBackId];

    }
}


@end
