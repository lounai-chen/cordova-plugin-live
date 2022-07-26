//
//  AlivcPublisherViewController.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcLivePusherViewController.h"
#import "AlivcPublisherView.h"
#import <AliyunQueenUIKit/AliyunQueenUIKit.h>
#import "AlivcPushViewsProtocol.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/time.h>
#import <CoreMotion/CMMotionManager.h>
#import "Masonry.h"
#import "ALLiveConfig.h"
#import "AlivcCommonUtils.h"
#import "LivePlugin.h"
//#import "UIView+Toast.h"

#import <AlivcLivePusher/AlivcLivePusher.h>
#import "ALLiveMonitorView.h"
#define kAlivcLivePusherVCAlertTag 89976
#define kAlivcLivePusherNoticeTimerInterval 5.0

#define TEST_EXTERN_YUV_BUFFER_SIZE 1280*720*3/2
#define TEST_EXTERN_PCM_BUFFER_SIZE 3200

#define TEST_EXTERN_YUV_DURATION 40000
#define TEST_EXTERN_PCM_DURATION 30000


@interface AlivcLivePusherViewController () <AlivcPublisherViewDelegate, AlivcMusicViewDelegate,AlivcAnswerGameViewDelegate,UIAlertViewDelegate,AlivcLivePusherInfoDelegate,AlivcLivePusherErrorDelegate,AlivcLivePusherNetworkDelegate,AlivcLivePusherBGMDelegate,AlivcLivePusherCustomFilterDelegate,AlivcLivePusherCustomDetectorDelegate, AlivcLivePusherSnapshotDelegate,AliLivePlayerDelegate>{
    
    dispatch_source_t _streamingTimer;
    int _userVideoStreamHandle;
    int _userAudioStreamHandle;
    FILE*  _videoStreamFp;
    FILE*  _audioStreamFp;
    int64_t _lastVideoPTS;
    int64_t _lastAudioPTS;
    char yuvData[TEST_EXTERN_YUV_BUFFER_SIZE];
    char pcmData[TEST_EXTERN_PCM_BUFFER_SIZE];
    AlivcLivePushResolution defaultRes;
    int defaultChannel;
    AlivcLivePushAudioSampleRate defaultSampleRate;
    
    
}

@property (nonatomic ,strong) LivePlugin *pluginCallBack;

// UI
@property (nonatomic, strong) UIView *playView;

@property (nonatomic, strong) AlivcPublisherView *publisherView;
@property (nonatomic, strong) AliyunQueenPanelController *beautyPanelController;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) NSTimer *noticeTimer;
@property (nonatomic, strong) ALLiveMonitorView *monitorView;

// flags
@property (nonatomic, assign) BOOL isAutoFocus;
@property (nonatomic, assign) BOOL g_flash; //闪光灯

// SDK
@property (nonatomic, strong) AlivcLivePusher *livePusher;
@property (nonatomic, strong) QueenEngine *queenEngine;
@property (nonatomic, strong) CMMotionManager* motionManager;
@end

static int mScreenRotation = 0;

int64_t getCurrentTimeUs()
{
    uint64_t ret;
    struct timeval time;
    gettimeofday(&time, NULL);
    ret = time.tv_sec * 1000000ll + (time.tv_usec);
    
    return ret;
}

@implementation AlivcLivePusherViewController

- (void)viewDidLoad {
     
    [super viewDidLoad];

    // zzy 20220316 横屏问题 add begin
    //self.allowSelectInterfaceOrientation = YES;
    // zzy 20220316 横屏问题 add end
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self initMotionManager];

    // 如果不需要退后台继续推流，可以参考这套退后台通知的实现。
    [self addBackgroundNotifications];

    
    [self setupSubviews];

    [self setupPlayer];
    
    [self setupDefaultValues];
    
    [self setupDebugTimer];

    defaultRes = self.pushConfig.resolution;
    defaultChannel = self.pushConfig.audioChannel;
    defaultSampleRate = self.pushConfig.audioSampleRate;

    int ret = [self setupPusher];

    if (ret != 0) {
        [self showPusherInitErrorAlert:ret];
        return;
    }

    ret = [self startPreview];

    if (ret != 0) {
        [self showPusherStartPreviewErrorAlert:ret isStart:YES];
        return;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // 监控数据view
     _monitorView = [[ALLiveMonitorView alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, 150)];
     _monitorView.backgroundColor = [UIColor clearColor];
     [self.view addSubview:_monitorView];
    _monitorView.hidden = YES;
    
    //self.view.backgroundColor  = [UIColor orangeColor  ];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)addUserStream {
    
    if(self.isUserMainStream) {
        
        if(!_streamingTimer) {
            
            _videoStreamFp = 0;
            _audioStreamFp = 0;
            _lastVideoPTS = 0;
            _lastAudioPTS = 0;

            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _streamingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_streamingTimer,DISPATCH_TIME_NOW,10*NSEC_PER_MSEC, 0);
            dispatch_source_set_event_handler(_streamingTimer, ^{
                
                if(!_videoStreamFp) {
                    NSString* userVideoPath = [[NSBundle mainBundle] pathForResource:@"capture" ofType:@"yuv"];
                    const char* video_path = [userVideoPath UTF8String];
                    _videoStreamFp = fopen(video_path, "rb");
                }
                
                if(!_audioStreamFp) {
                    NSString* userAudioPath = [[NSBundle mainBundle] pathForResource:@"441" ofType:@"pcm"];
                    const char* audio_path = [userAudioPath UTF8String];
                    _audioStreamFp = fopen(audio_path, "rb");
                }
                
                if(_videoStreamFp) {
                    
                    int64_t nowTime = getCurrentTimeUs();
                    if(nowTime  - _lastVideoPTS >= TEST_EXTERN_YUV_DURATION) {
                        
                        int dataSize = TEST_EXTERN_YUV_BUFFER_SIZE;
                        size_t size = fread((void *)yuvData, 1, dataSize, _videoStreamFp);
                        if(size<dataSize) {
                             fseek(_videoStreamFp,0,SEEK_SET);
                             size = fread((void *)yuvData, 1, dataSize, _videoStreamFp);
                        }
                        
                        if(size == dataSize) {
                            if(self.isUserMainStream) {
                                [self.livePusher sendVideoData:yuvData width:720 height:1280 size:dataSize pts:nowTime rotation:0];
                            }
                        }
                        _lastVideoPTS = nowTime;
                    }
                }
                
                if(_audioStreamFp) {
                    
                    int64_t nowTime = getCurrentTimeUs();
                    
                    if(nowTime  - _lastAudioPTS >= TEST_EXTERN_PCM_DURATION) {
                        
                        int dataSize = TEST_EXTERN_PCM_BUFFER_SIZE;
                        size_t size =fread((void *)pcmData, 1, dataSize,  _audioStreamFp);
                        if(size<dataSize){
                            fseek(_audioStreamFp,0,SEEK_SET);
                        }
                        
                        if(size > 0) {
                            if(self.isUserMainStream){
                                [self.livePusher sendPCMData:pcmData size:(int)size sampleRate:44100 channel:1 pts:nowTime];
                            }
                        }
                        _lastAudioPTS = nowTime;
                        
                    }
                }
                
            });
            dispatch_resume(_streamingTimer);
        }
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeLeft) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}


#pragma mark - SDK

/**
 创建推流
 */
- (int)setupPusher {
   
    if(self.isUserMainStream) {
        
        self.pushConfig.externMainStream = true;
        self.pushConfig.resolution  = defaultRes;
        self.pushConfig.audioChannel = defaultChannel;
        self.pushConfig.audioSampleRate = defaultSampleRate;
        self.pushConfig.externVideoFormat = AlivcLivePushVideoFormatYUVNV12;
        
    }else {
        
        self.pushConfig.externMainStream = false;
        self.pushConfig.resolution  = defaultRes;
        self.pushConfig.audioChannel = defaultChannel;
        self.pushConfig.audioSampleRate = defaultSampleRate;
    }
    self.livePusher = [[AlivcLivePusher alloc] initWithConfig:self.pushConfig];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
                      
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self.livePusher setLogPath:cacheDirectory maxPartFileSizeInKB:100*1024*1024];
    
    [self.livePusher setLogLevel:(AlivcLivePushLogLevelDebug)];
    if (!self.livePusher) {
        return -1;
    }
    [self.livePusher setInfoDelegate:self];
    [self.livePusher setErrorDelegate:self];
    [self.livePusher setNetworkDelegate:self];
    [self.livePusher setBGMDelegate:self];
    [self.livePusher setSnapshotDelegate:self];
    [self.livePusher setCustomFilterDelegate:self];
    [self.livePusher setCustomDetectorDelegate:self];
    
    return 0;
}

#pragma mark 按钮事件
- (void)CameraDirection{
    if (self.livePusher) {
        [self.livePusher switchCamera];
    }
}

- (void)LiveFlash {
    self.g_flash = !self.g_flash;
    if (self.livePusher) {
        [self.livePusher setFlash:self.g_flash?true:false];
    }
}

/**
 销毁推流
 */
- (void)destoryPusher {
    
    if(_streamingTimer) {
        dispatch_cancel(_streamingTimer);
        _streamingTimer = 0;
    }
    
    if(_videoStreamFp) {
        fclose(_videoStreamFp);
        _videoStreamFp = 0;
    }
    
    if(_audioStreamFp) {
        fclose(_audioStreamFp);
        _audioStreamFp = 0;
    }
    
    //[self stopPush];
    //[self stopPreview] ;
    
   
    
    if (self.livePusher) {
        [self.livePusher destory];
    }
    
    self.livePusher = nil;
    
}

/**
 开始预览plugin
 */
- (int)startPreviewPlugin {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPreviewAsync:self.previewView];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher startPreview:self.previewView];
    }
    return ret;
}

/**
 开始预览
 */
- (int)startPreview {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPreviewAsync:self.previewView];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher startPreview:self.previewView];
    }
    return ret;
}

/**
 停止预览plugin
 */
- (int)StopPreviewPlugin {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = [self.livePusher stopPreview];
    return ret;
}

/**
 停止预览
 */
- (int)stopPreview {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = [self.livePusher stopPreview];
    return ret;
}

/**
 开始推流 plugin
 */
- (int) start {
    if (!self.livePusher) {
        return -1;
    }
    
    // 鉴权测试时，使用Auth A类型的URL。
    [self updateAuthURL];
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPushWithURLAsync:self.pushURL];
    
    } else {
        // 使用同步接口
        ret = [self.livePusher startPushWithURL:self.pushURL];
    }
    
    return ret;
}

/**
 开始推流
 */
- (int) startPush {
    if (!self.livePusher) {
        return -1;
    }
    
    // 鉴权测试时，使用Auth A类型的URL。
    [self updateAuthURL];
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPushWithURLAsync:self.pushURL];
    
    } else {
        // 使用同步接口
        ret = [self.livePusher startPushWithURL:self.pushURL];
    }
    
    return ret;
}


/**
 停止推流
 */
- (int)stopPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = [self.livePusher stopPush];
    return ret;
}

/**
 停止推流 plugin
 */
- (int)stop {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = [self.livePusher stopPush];
    
    [self cancelTimer];
    [self destoryPusher];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
   
    return ret;
}

/**
 暂停推流plugin
 */
- (int)pausePushPlugin {
    
    if (!self.livePusher) {
        return -1;
    }

    int ret = [self.livePusher pause];
    return ret;
}

/**
 暂停推流
 */
- (int)pausePush {
    
    if (!self.livePusher) {
        return -1;
    }

    int ret = [self.livePusher pause];
    return ret;
}

/**
 恢复推流plugin
 */
- (int)resumePushPlugin {
   
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;

    if (self.isUseAsyncInterface) {
        // 使用异步接口
       ret = [self.livePusher resumeAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher resume];
    }
    return ret;
}


/**
 恢复推流
 */
- (int)resumePush {
   
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;

    if (self.isUseAsyncInterface) {
        // 使用异步接口
       ret = [self.livePusher resumeAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher resume];
    }
    return ret;
}

/**
 重新推流plugin
 */
- (int)restartPushPlugin {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher restartPushAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher restartPush];
    }
    return ret;
}


/**
 重新推流
 */
- (int)restartPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher restartPushAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher restartPush];
    }
    return ret;
}

//播放视频
- (void) PlayerStart {
    
    [self.livePlayer startWithURL: self.playUrl];
   
}


- (void)reconnectPush {
    
    if (!self.livePusher) {
        return;
    }
    
    [self.livePusher reconnectPushAsync];
}

#pragma mark - Queen Beauty

- (void)initQueenBeauty
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ALLiveConfig sharedInstance] resetRaceBeautyConfig];
    });
    QueenEngineConfigInfo* configInfo = [[QueenEngineConfigInfo alloc] init];
    configInfo.withContext = NO;
    configInfo.autoSettingImgAngle = NO;
    self.queenEngine = [[QueenEngine alloc] initWithConfigInfo:configInfo];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.beautyPanelController.queenEngine = self.queenEngine;
        [self.queenEngine setQueenBeautyType:kQueenBeautyTypeSkinBuffing enable:YES];
        [self.queenEngine setQueenBeautyType:kQueenBeautyTypeSkinWhiting enable:YES];
        [self.queenEngine setQueenBeautyParams:kQueenBeautyParamsWhitening value:0.8f];
        [self.queenEngine setQueenBeautyParams:kQueenBeautyParamsSharpen value:0.6f];
        [self.queenEngine setQueenBeautyParams:kQueenBeautyParamsSkinBuffing value:0.6];
    });
}

#pragma mark - AlivcLivePusherErrorDelegate

- (void)onSystemError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {

    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+11
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"system_error", nil)
                            delegate:self
                         cancelTitle:NSLocalizedString(@"exit", nil)
                   otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
   
    NSString *msg =@"-10|推流未知错误";
    [self.pluginCallBack sendCmd: msg];
}


- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+12
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"sdk_error", nil)
                            delegate:self
                         cancelTitle:NSLocalizedString(@"exit", nil)
                   otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    
    NSString *msg =@"-10|推流SDK相关错误";
    [self.pluginCallBack sendCmd: msg];
}



#pragma mark - AlivcLivePusherNetworkDelegate

- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+23
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"connect_fail", nil)
                            delegate:self
                         cancelTitle:NSLocalizedString(@"reconnect_button", nil)
                   otherButtonTitles:NSLocalizedString(@"exit", nil), nil];
    
    NSString *msg =@"-18|连接失败";
    [self.pluginCallBack sendCmd: msg];

}


- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"senddata_timeout", nil)
                            delegate:nil
                         cancelTitle:NSLocalizedString(@"ok", nil)
                   otherButtonTitles:nil];
    NSString *msg =@"-17|发送数据超时";
    [self.pluginCallBack sendCmd: msg];
}

- (void)onSendSeiMessage:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"send message", nil)];

}


- (void)onConnectRecovery:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"connectRecovery_log", nil)];
}


- (void)onNetworkPoor:(AlivcLivePusher *)pusher {
    
    [self showAlertViewWithErrorCode:0 errorStr:nil tag:0 title:NSLocalizedString(@"dialog_title", nil) message:NSLocalizedString(@"当前网速较慢，请检查网络状态", nil) delegate:nil cancelTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
    NSString *msg =@"-12|网络不稳定,稍后重试";
    [self.pluginCallBack sendCmd: msg];
}


- (void)onReconnectStart:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"reconnect_start", nil)];
}


- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"reconnect_success", nil)];
}

- (void)onConnectionLost:(AlivcLivePusher *)pusher {
    
}


- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+22
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"reconnect_fail", nil)
                            delegate:self
                         cancelTitle:NSLocalizedString(@"reconnect_button", nil)
                   otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    
    NSString *msg =@"-15|重新连接失败";
    [self.pluginCallBack sendCmd: msg];

}

- (NSString *)onPushURLAuthenticationOverdue:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:@"Auth push url update"];
    
    if(!self.livePusher.isPushing) {
         NSLog(@"推流url鉴权即将过期。更新url");
         [self updateAuthURL];
    }
    return self.pushURL;
}

- (void)onPacketsLost:(AlivcLivePusher *)pusher {
    
}


#pragma mark - AlivcLivePusherInfoDelegate

- (void)onPreviewStarted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"start_preview_log", nil)];
    if (self.beautyOn && !self.pushConfig.audioOnly) {
        [self initQueenBeauty];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addUserStream];
    });
    
    NSString *msg =@"100|开启预览";
    [self.pluginCallBack sendCmd: msg];

}


- (void)onPreviewStoped:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"stop_preview_log", nil)];
    
    NSString *msg =@"100|开启预览";
    [self.pluginCallBack sendCmd: msg];
}

- (void)onPushStarted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"start_push_log", nil)];
    
    NSString *msg =@"102|开启推流";
    [self.pluginCallBack sendCmd: msg];
}


- (void)onPushPaused:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"pause_push_log", nil)];
    
    NSString *msg =@"104|暂停";
    [self.pluginCallBack sendCmd: msg];
}


- (void)onPushResumed:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"resume_push_log", nil)];
    
    NSString *msg =@"104|恢复";
    [self.pluginCallBack sendCmd: msg];
}


- (void)onPushStoped:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"stop_push_log", nil)];
    
    NSString *msg =@"100|停止推流";
    [self.pluginCallBack sendCmd: msg];
}


- (void)onFirstFramePreviewed:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"first_frame_log", nil)];
}


- (void)onPushRestart:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"restart_push_log", nil)];
    
    NSString *msg =@"106|重新推流成功";
    [self.pluginCallBack sendCmd: msg];
}


#pragma mark - AlivcLivePusherBGMDelegate

- (void)onStarted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"BGM Start", nil)];
}


- (void)onStoped:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"BGM Stop", nil)];
}


- (void)onPaused:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"BGM Pause", nil)];
}


- (void)onResumed:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"bgm Resume", nil)];
}


- (void)onProgress:(AlivcLivePusher *)pusher progress:(long)progress duration:(long)duration {
    
    [self.publisherView updateMusicDuration:progress totalTime:duration];
}


- (void)onCompleted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"BGM Play Complete", nil)];
}


- (void)onOpenFailed:(AlivcLivePusher *)pusher {
    
    [self.publisherView resetMusicButtonTypeWithPlayError];
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"BGM File Open Failed", nil)
                            delegate:self
                         cancelTitle:NSLocalizedString(@"ok", nil)
                   otherButtonTitles:nil];
}


- (void)onDownloadTimeout:(AlivcLivePusher *)pusher {
    
    [self.publisherView resetMusicButtonTypeWithPlayError];
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:NSLocalizedString(@"BGM Download Timeout", nil)
                            delegate:self
                         cancelTitle:NSLocalizedString(@"ok", nil)
                   otherButtonTitles:nil];
}

#pragma mark - AlivcLivePusherCustomFilterDelegate
/**
 通知外置滤镜创建回调
 */
- (void)onCreate:(AlivcLivePusher*)pusher context:(void*)context
{
    
}


/**
 通知外置滤镜处理回调
 */
- (int)onProcess:(AlivcLivePusher *)pusher texture:(int)texture textureWidth:(int)width textureHeight:(int)height extra:(long)extra
{
    if (self.beautyOn && nil != self.queenEngine) {
        QETextureData* textureData = [[QETextureData alloc] init];
        textureData.inputTextureID = texture;
        textureData.width = width;
        textureData.height = height;
        kQueenResultCode result = [self.queenEngine processTexture:textureData];
        if (result != kQueenResultCodeOK) {
//            NSLog(@"queen beauty processTexture error. code: %lu", result);
        }
        return textureData.outputTextureID;
    }
    return texture;
}
/**
 通知外置滤镜销毁回调
 */
- (void)onDestory:(AlivcLivePusher*)pusher
{
    if (nil != self.queenEngine) {
        [self.queenEngine destroyEngine];
        self.queenEngine = nil;
    }
}

#pragma mark - AlivcLivePusherCustomDetectorDelegate
/**
 通知外置视频检测创建回调
 */
- (void)onCreateDetector:(AlivcLivePusher *)pusher
{
#if USE_SENSEME
#eif USE_TAOPAI
#else
//    [[AlivcLibFaceManager shareManager] create];
#endif
}
/**
 通知外置视频检测处理回调
 */
- (long)onDetectorProcess:(AlivcLivePusher*)pusher data:(long)data w:(int)w h:(int)h rotation:(int)rotation format:(int)format extra:(long)extra
{
    if (self.beautyOn && nil != self.queenEngine) {
        int screenRotation = 0;
        if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeLeft) {
            screenRotation = -90;
        } else if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeRight) {
            screenRotation = 90;
        }
        
        unsigned char *rgbBuffer = malloc(w * h * 3);
        [AlivcCommonUtils nv12toRGBWithYUV:(unsigned char *)data withRGB:(unsigned char *)rgbBuffer withWidht:w withHeight:h];
        [self.queenEngine updateInputDataAndRunAlg:(uint8_t*)rgbBuffer
                                     withImgFormat:kQueenImageFormatRGB
                                         withWidth:w
                                        withHeight:h
                                        withStride:0
                                    withInputAngle:(mScreenRotation + screenRotation + 360) % 360
                                   withOutputAngle:(mScreenRotation + screenRotation + 360) % 360
                                      withFlipAxis:0];
        free(rgbBuffer);
    }
    return data;
}

/**
 通知外置视频检测销毁回调
 */
- (void)onDestoryDetector:(AlivcLivePusher *)pusher
{
//    [[AlivcLibFaceManager shareManager] destroy];
}

#pragma mark - AlivcLivesNAPSHOTDelegate
- (void)onSnapshot:(AlivcLivePusher *)pusher image:(UIImage *)image
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss-SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString* fileName = [NSString stringWithFormat:@"snapshot-%@.png", dateString];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:
                          [NSString stringWithFormat:fileName]];
    
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath   atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        NSLog(@"保存成功");
            dispatch_async(dispatch_get_main_queue(), ^{

//                [self.view makeToast:@"保存成功"];
//                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);

            });

    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"截图已保存" message:filePath delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView show];
//    });
     
}

#pragma mark - 退后台停止推流的实现方案

- (void)addBackgroundNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}


- (void)applicationWillResignActive:(NSNotification *)notification {

    if (!self.livePusher) {
        return;
    }
    
    // 如果退后台不需要继续推流，则停止推流
    if ([self.livePusher isPushing]) {
        [self.livePusher stopPush];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

    if (!self.livePusher) {
        return;
    }
    
    if ([self.publisherView getPushButtonType]) {
        // 当前是推流模式，恢复推流
        [self.livePusher startPushWithURLAsync:self.pushURL];
    }
}

#pragma mark - AlivcPublisherViewDelegate

//返回，停止预览，停止推流
- (void)publisherOnClickedBackButton {
    // zzy 20220316 横屏问题 add begin
//    self.allowSelectInterfaceOrientation = NO;
    // zzy 20220316 横屏问题 add end
    
    [self cancelTimer];
    [self destoryPusher];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (int)publisherOnClickedPreviewButton:(BOOL)isPreview button:(UIButton *)sender {
    
    int ret = 0;
    
    if (isPreview) {
        ret = [self startPreview];
        if (ret != 0) {
            [self showPusherStartPreviewErrorAlert:ret isStart:YES];
            [sender setSelected:!sender.selected];
        }
    } else {
        ret = [self stopPreview];
        if (ret != 0) {
            [self showPusherStartPreviewErrorAlert:ret isStart:NO];
            [sender setSelected:!sender.selected];
        }
    }
    
    return ret;
}

- (BOOL)publisherOnClickedPushButton:(BOOL)isPush button:(UIButton *)sender {
    
    if (isPush) {
        // 开始推流
        int ret = [self startPush];
        if (ret != 0) {
            [self showPusherStartPushErrorAlert:ret isStart:YES];
            [sender setSelected:!sender.selected];
            return NO;
        }
        return YES;
    } else {
        // 停止推流
        int ret = [self stopPush];
        if (ret != 0) {
            [self showPusherStartPushErrorAlert:ret isStart:NO];
            [sender setSelected:!sender.selected];
            return NO;
        }
        return YES;
    }
}

- (void)publisherOnClickedPauseButton:(BOOL)isPause button:(UIButton *)sender {
    
    if (isPause) {
        int ret = [self pausePush];
        if (ret != 0) {
            [self showPusherPausePushErrorAlert:ret isPause:YES];
            [sender setSelected:!sender.selected];
        }

    } else {
        int ret = [self resumePush];
        if (ret != 0) {
            [self showPusherPausePushErrorAlert:ret isPause:NO];
            [sender setSelected:!sender.selected];
        }
    }
}


- (int)publisherOnClickedRestartButton {
    
    int ret = [self restartPush];
    if (ret != 0) {
        
        [self showAlertViewWithErrorCode:ret
                                errorStr:nil
                                     tag:0
                                   title:NSLocalizedString(@"dialog_title", nil)
                                 message:@"Restart Error"
                                delegate:nil
                             cancelTitle:NSLocalizedString(@"ok", nil)
                       otherButtonTitles:nil];
    }
    
    return ret;
}

- (void)publisherOnClickedSwitchCameraButton {
    
    if (self.livePusher) {
        [self.livePusher switchCamera];
    }
}

- (void)publisherOnClickedSnapshotButton {
    
    if (self.livePusher) {
        [self.livePusher snapshot:1 interval:0];
    }
}

- (void)publisherOnClickedFlashButton:(BOOL)flash button:(UIButton *)sender {
    
    if (self.livePusher) {
        [self.livePusher setFlash:flash?true:false];
    }
}

- (void)publisherOnClickedBeautyButton:(BOOL)beautyOn {
    [self.beautyPanelController showPanel:YES];
}

- (void)publisherOnClickedZoom:(CGFloat)zoom {
    
    if (self.livePusher) {
        CGFloat max = [_livePusher getMaxZoom];
        [self.livePusher setZoom:MIN(zoom, max)];
    }
}


- (void)publisherOnClickedFocus:(CGPoint)focusPoint {
    
    if (self.livePusher) {
        [self.livePusher focusCameraAtAdjustedPoint:focusPoint autoFocus:self.isAutoFocus];
    }
}

- (void)publisherSliderBeautyWhiteValueChanged:(int)value {
    
}


- (void)publisherSliderBeautyBuffingValueChanged:(int)value {
 
}

- (void)publisherSliderBeautyCheekPinkValueChanged:(int)value{

}


- (void)publisherSliderBeautyRubbyValueChanged:(int)value {
    
}

- (void)publisherSliderBeautyThinFaceValueChanged:(int)value{
    
}

- (void)publisherSliderBeautyShortenFaceValueChanged:(int)value{
    
}

- (void)publisherSliderBeautyBigEyeValueChanged:(int)value{
    
}


- (void)publisherOnBitrateChangedTargetBitrate:(int)targetBitrate {
    
    if (self.livePusher) {
        
        int ret = [self.livePusher setTargetVideoBitrate:targetBitrate];
        if (ret != 0) {
            
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:NSLocalizedString(@"dialog_title", nil)
                                     message:NSLocalizedString(@"bite_error", nil)
                                    delegate:nil
                                 cancelTitle:NSLocalizedString(@"ok", nil)
                           otherButtonTitles:nil];
        }
    }
}


- (void)publisherOnBitrateChangedMinBitrate:(int)minBitrate {
    
    if (self.livePusher) {
        int ret = [self.livePusher setMinVideoBitrate:minBitrate];
    
        if (ret != 0) {
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:NSLocalizedString(@"dialog_title", nil)
                                     message:NSLocalizedString(@"bite_error", nil)
                                    delegate:nil
                                 cancelTitle:NSLocalizedString(@"ok", nil)
                           otherButtonTitles:nil];
        }
    }
}


- (void)publisherOnClickPushMirrorButton:(BOOL)isPushMirror {
    
    if (self.livePusher) {
        [self.livePusher setPushMirror:isPushMirror?true:false];
    }
}

- (void)publisherOnSelectPreviewDisplayMode:(int)mode {
    if (self.livePusher) {
        [self.livePusher setpreviewDisplayMode:mode];
    }
}


- (void)publisherOnClickPreviewMirrorButton:(BOOL)isPreviewMorror {
    
    if (self.livePusher) {
        [self.livePusher setPreviewMirror:isPreviewMorror?true:false];
    }
}


- (void)publisherOnClickAutoFocusButton:(BOOL)isAutoFocus {
    
    if (self.livePusher) {
        [self.livePusher setAutoFocus:isAutoFocus?true:false];
        self.isAutoFocus = isAutoFocus;
    }
}

- (int)publisherOnClickAddDynamically:(NSString *)path x:(float)x y:(float)y w:(float)w h:(float)h
{
    if (self.livePusher) {
        return [self.livePusher addDynamicWaterMarkImageDataWithPath:path x:x y:y w:w h:h];
    }
    return -1;
}

- (void)publisherOnClickRemoveDynamically:(int)vid
{
    if (self.livePusher) {
        [self.livePusher removeDynamicWaterMark:vid];
    }
}


#pragma mark - AlivcMusicViewDelegate

- (void)musicOnClickPlayButton:(BOOL)isPlay musicPath:(NSString *)musicPath {
    
    if (self.livePusher) {
        if (isPlay) {
            [self.livePusher startBGMWithMusicPathAsync:musicPath];
        } else {
            [self.livePusher stopBGMAsync];
        }
    }
}

- (void)musicOnClickPauseButton:(BOOL)isPause {
    
    if (self.livePusher) {
        if (isPause) {
            [self.livePusher pauseBGM];
        } else {
            [self.livePusher resumeBGM];
        }
    }
}


- (void)musicOnClickLoopButton:(BOOL)isLoop {
    
    if (self.livePusher) {
        [self.livePusher setBGMLoop:isLoop?true:false];
    }
}


- (void)musicOnClickDenoiseButton:(BOOL)isDenoiseOpen {
    
    if (self.livePusher) {
        [self.livePusher setAudioDenoise:isDenoiseOpen];
    }
}

- (void)musicOnClickMuteButton:(BOOL)isMute {
    
    if (self.livePusher) {
        [self.livePusher setMute:isMute?true:false];
    }
}

- (void)musicOnClickEarBackButton:(BOOL)isEarBack {
    
    if (self.livePusher) {
        [self.livePusher setBGMEarsBack:isEarBack?true:false];
    }
}

- (void)musicOnSliderAccompanyValueChanged:(int)value {
    
    if (self.livePusher) {
        [self.livePusher setBGMVolume:value];
    }
}

- (void)musicOnSliderVoiceValueChanged:(int)value {
    
    if (self.livePusher) {
        [self.livePusher setCaptureVolume:value];
    }
}


#pragma mark - AlivcAnswerGameViewDelegate

- (void)answerGameOnSendQuestion:(NSString *)question questionId:(NSString *)questionId {
    
    if (self.livePusher) {
        // 先插入SEI信息到流里面，在对server做一个请求告知发送题目
        int ret = [self.livePusher sendMessage:question repeatCount:100 delayTime:0 KeyFrameOnly:false];
        if (ret != 0) {
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:NSLocalizedString(@"dialog_title", nil)
                                     message:@"Send Question Error"
                                    delegate:nil
                                 cancelTitle:NSLocalizedString(@"ok", nil)
                           otherButtonTitles:nil];
            return;
        }
        
        [self sendAnswerPostWithQuestionId:questionId expiredSeconds:@"100"];
    }
}



- (void)answerGameOnSendAnswer:(NSString *)answer duration:(NSInteger)duration {
    
    if (self.livePusher) {
        int repeatCount = (int)duration*self.pushConfig.fps;
        int ret = [self.livePusher sendMessage:answer repeatCount:repeatCount delayTime:0 KeyFrameOnly:false];
        if (ret != 0) {
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:NSLocalizedString(@"dialog_title", nil)
                                     message:@"Send Answer Error"
                                    delegate:nil
                                 cancelTitle:NSLocalizedString(@"ok", nil)
                           otherButtonTitles:nil];
        }
    }
}


- (void)sendAnswerPostWithQuestionId:(NSString *)questionId expiredSeconds:(NSString *)expiredSeconds {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://101.132.137.92/mgr/pushQuestion"]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    // lieId对应为播放端的拉流地址 去掉rtmp头 去掉authKey
    NSString *urlSting = self.pushURL;
    if ([urlSting containsString:@"auth_key"]) {
        urlSting = [[urlSting componentsSeparatedByString:@"?auth_key"] firstObject];
    }
    NSString *liveId = [[[urlSting componentsSeparatedByString:@"rtmp://"] lastObject] stringByReplacingOccurrencesOfString:@"push" withString:@"pull"];
    NSDictionary *param = @{@"liveId":liveId,
                            @"questionId":questionId,
                            @"expiredSeconds":@(15),
                            @"seiDelay":@(2000),
                            @"noSEI":@"true"};
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showAlertViewWithErrorCode:error.code errorStr:error.description tag:0 title:@"Error" message:@"Request Answer Game HTTP Error" delegate:nil cancelTitle:@"OK" otherButtonTitles:nil];
            } else {
                [self.publisherView updateInfoText:NSLocalizedString(@"Request Answer Game HTTP  Success", nil)];
            }
        });
    }];
    [sessionDataTask resume];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kAlivcLivePusherVCAlertTag+11 ||
        alertView.tag == kAlivcLivePusherVCAlertTag+12 ||
        alertView.tag == kAlivcLivePusherVCAlertTag+31 ||
        alertView.tag == kAlivcLivePusherVCAlertTag+32 ||
        alertView.tag == kAlivcLivePusherVCAlertTag+33) {
        
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self publisherOnClickedBackButton];
        }
    }
    
    if (alertView.tag == kAlivcLivePusherVCAlertTag+22 ||
        alertView.tag == kAlivcLivePusherVCAlertTag+23) {
        
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self reconnectPush];
        } else {
            [self publisherOnClickedBackButton];
        }
    }
}

#pragma - UI

- (void)setupPlayer {

    //self.livePlayer = [[AliLivePlayer alloc] initWithConfiguration:self.configuration];
    // 初始化 livePlayer
    
    self.livePlayer = [[AliLivePlayer alloc] init];
    self.livePlayer.delegate = self;
    [self.livePlayer setSetRenderView:self.playView];
}

- (void)setupSubviews {
    
    UIView *view1 = [[UIView alloc]initWithFrame:[self getFullScreenFrame]];
    view1.backgroundColor = [UIColor greenColor];

    self.playView = [[UIView alloc] initWithFrame:CGRectMake(5, 50, [self width] - 10, 200)];
    self.playView.backgroundColor = [UIColor lightGrayColor];
    self.playView.translatesAutoresizingMaskIntoConstraints = false;
    
    
    self.view.frame  = [self getFullScreenFrame];
    
    [view1 addSubview:self.previewView];

    [view1 addSubview:self.playView];
    
    [self.view addSubview: view1];
    
    
   // [self.view addSubview: self.previewView];
    
   
   
    
    // [self.view addSubview: self.publisherView];
}

- (void)showPusherInitErrorAlert:(int)error {
    
    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:kAlivcLivePusherVCAlertTag+31
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:@"Init AlivcLivePusher Error"
                            delegate:self
                         cancelTitle:NSLocalizedString(@"exit", nil)
                   otherButtonTitles:nil];
}

- (void)showPusherStartPreviewErrorAlert:(int)error isStart:(BOOL)isStart {
    
    NSString *message = @"Stop Preview Error";
    NSInteger tag = 0;
    if (isStart) {
        message = @"Start Preview Error";
        tag = kAlivcLivePusherVCAlertTag+32;
    }
    
    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:tag
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:message
                            delegate:self
                         cancelTitle:NSLocalizedString(@"ok", nil)
                   otherButtonTitles:nil];
}


- (void)showPusherStartPushErrorAlert:(int)error isStart:(BOOL)isStart {
    
    NSString *message = @"Stop Push Error";
    if (isStart) {
        message = @"Start Push Error";
    }

    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:0
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:message
                            delegate:nil
                         cancelTitle:NSLocalizedString(@"ok", nil)
                   otherButtonTitles:nil];
}


- (void)showPusherPausePushErrorAlert:(int)error isPause:(BOOL)isPause {
    
    NSString *message = @"Pause Error";
    if (isPause) {
        message = @"Resume Error";
    }
    
    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:0
                               title:NSLocalizedString(@"dialog_title", nil)
                             message:message
                            delegate:nil
                         cancelTitle:NSLocalizedString(@"ok", nil)
                   otherButtonTitles:nil];
}


- (void)setupDefaultValues {
    self.g_flash = false;
    self.isAutoFocus = self.pushConfig.autoFocus;
}

- (void)showAlertViewWithErrorCode:(NSInteger)errorCode errorStr:(NSString *)errorStr tag:(NSInteger)tag title:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelTitle:(NSString *)cancel otherButtonTitles:(NSString *)otherTitles, ... {
    
    if (errorCode == ALIVC_LIVE_PUSHER_PARAM_ERROR) {
        errorStr = NSLocalizedString(@"接口输入参数错误",nil);
    }
    
    if (errorCode == ALIVC_LIVE_PUSHER_SEQUENCE_ERROR) {
        errorStr = NSLocalizedString(@"接口调用顺序错误",nil);
    }
    
    if(errorCode == ALIVC_LIVE_PUSHER_RTC_NOT_SUPPORT_AUDIO_OR_VIDEOONLY_PUSH) {
        errorStr = NSLocalizedString(@"RTC协议暂不支持推纯音频或纯视频流",nil);
    }
    
    NSString *showMessage = [NSString stringWithFormat:@"%@: code:%lx message:%@", message, errorCode, errorStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:showMessage delegate:delegate cancelButtonTitle:cancel otherButtonTitles: otherTitles,nil];
        if (tag) {
            alert.tag = tag;
        }
        [alert show];
    });
}

- (CGFloat)width {
    return self.view.frame.size.width;
}

- (CGFloat)height {
    return self.view.frame.size.height;
}


#pragma mark - Timer

- (void)setupDebugTimer {
    
    self.noticeTimer = [NSTimer scheduledTimerWithTimeInterval:kAlivcLivePusherNoticeTimerInterval target:self selector:@selector(noticeTimerAction:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.noticeTimer forMode:NSDefaultRunLoopMode];
}

- (void)cancelTimer{
    
    if (self.noticeTimer) {
        [self.noticeTimer invalidate];
        self.noticeTimer = nil;
    }
}


- (void)noticeTimerAction:(NSTimer *)sender {
    
    if (!self.livePusher) {
        return;
    }

    BOOL isPushing = [self.livePusher isPushing];
    NSString *text = @"";
    if (isPushing) {
        text = [NSString stringWithFormat:@"%@:%@|%@:%@",NSLocalizedString(@"ispushing_log", nil), isPushing?@"YES":@"NO", NSLocalizedString(@"push_url_log", nil), [self.livePusher getPushURL]];
    } else {
        // 未推流
        text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"un_ispushing_log", nil)];
    }

    [self.publisherView updateInfoText:text];
    [self monitorInfo];
}

- (void)publisherDataMonitorView {
    self.monitorView.hidden =  !self.monitorView.hidden;
}

- (void)monitorInfo{
    AlivcLivePushStatsInfo *info = [self.livePusher getLivePushStatusInfo];
    self.monitorView.titleLabel.text = NSLocalizedString(@"本地视频统计信息",nil);
    self.monitorView.sentBitrateLabel.text = [NSString stringWithFormat:@"%@ %d kbps",NSLocalizedString(@"发送码率：",nil), info.videoEncodedBitrate];
    self.monitorView.sentFpsLabel.text = [NSString stringWithFormat:@"%@ %d fps",NSLocalizedString(@"编码帧率：",nil),info.videoEncodedFps];
//    self.monitorView.encodeFpsLabel.text = [NSString stringWithFormat:@"编码帧率：%d fps",info.videoEncodedFps];
}

#pragma mark - 懒加载

- (AlivcPublisherView *)publisherView {
    
    if (!_publisherView) {
        _publisherView = [[AlivcPublisherView alloc] initWithFrame:[self getFullScreenFrame]
                                                            config:self.pushConfig];
        [_publisherView setPushViewsDelegate:self];
        //_publisherView.backgroundColor = [UIColor clearColor];
        _publisherView.backgroundColor = [UIColor redColor];
    }
    return _publisherView;
}

- (AliyunQueenPanelController *)beautyPanelController
{
    if (!_beautyPanelController)
    {
        _beautyPanelController = [[AliyunQueenPanelController alloc] initWithParentView:self.view];
//        [_beautyPanelController selectEmptyBeautyEffect];
    }
    return _beautyPanelController;
}

- (UIView *)previewView {
    
//    if (!_previewView) {
//        _previewView = [[UIView alloc] init];
//        //_previewView.opaque = NO;
//        _previewView.backgroundColor = [UIColor clearColor];
//        //_previewView.backgroundColor = [UIColor blueColor];
//        //_previewView.frame = [self getFullScreenFrame_previewView];
//
//        //[self.webView.superview addSubview: _previewView];
//       // [self.webView bringSubviewToFront: _previewView];
//    }
//    return _previewView;
    
    
    if (!_previewView) {
            _previewView = [[UIView alloc] init];
            _previewView.backgroundColor = [UIColor clearColor];
       // _previewView.superview.backgroundColor = [UIColor yellowColor];
            _previewView.frame = [self getFullScreenFrame_previewView];
        }
        return _previewView;
}

- (CGRect)getFullScreenFrame_previewView {
    
    CGRect frame = self.view.bounds;
//    if (IPHONEX) {
//        // iPhone X UI适配
//        frame = CGRectMake(0, 0, AlivcScreenWidth, AlivcScreenHeight);
//    }
    
    //if (self.pushConfig.orientation != AlivcLivePushOrientationPortrait) {
        CGFloat temSize = frame.size.height;
    frame.size.height =  300;
        frame.size.width = 300;
        
        CGFloat temPoint = frame.origin.y;
    frame.origin.y =100; //frame.origin.x;
    frame.origin.x = 100;//temPoint;

   // }
    return frame;
}

- (CGRect)getFullScreenFrame {
    
    CGRect frame = self.view.bounds;
//    if (IPHONEX) {
//        // iPhone X UI适配
//        frame = CGRectMake(0, 0, AlivcScreenWidth, AlivcScreenHeight);
//    }
    
    if (self.pushConfig.orientation != AlivcLivePushOrientationPortrait) {
        CGFloat temSize = frame.size.height;
    frame.size.height =  frame.size.width;
        frame.size.width = temSize;
        
        CGFloat temPoint = frame.origin.y;
        frame.origin.y = frame.origin.x;
        frame.origin.x = temPoint;

    }
    return frame;
}


#pragma mark - Auth

// 以下为测试鉴权使用，一般场景下，建议使用APPServer下发推流地址。Auth计算参考官方文档
- (void)updateAuthURL {
    
    if (self.authKey && self.authDuration) {
        // 开启测试鉴权的情况下，拼接鉴权A类型URL
        NSString *authPushURL = [self getAuthTestPushURLWithDuation:[self.authDuration integerValue] authKey:self.authKey];
        self.pushURL = authPushURL;
    }
}

- (NSString *)getAuthTestPushURLWithDuation:(NSInteger)duration authKey:(NSString *)authKey {
    
    NSString *basePushURL = [[self.pushURL componentsSeparatedByString:@"?auth_key="] firstObject];
    NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
    
    NSInteger timestamp = currentTime + duration;
    
    NSString *uri = [[self.pushURL componentsSeparatedByString:@"push-videocall.aliyuncs.com"] lastObject];
    NSString *hash = [self MD5ForLower32Bate:[NSString stringWithFormat:@"%@-%ld-0-0-%@",uri, timestamp, authKey]];
    
    NSString *newPushURL = [NSString stringWithFormat:@"%@?auth_key=%ld-0-0-%@", basePushURL, timestamp, hash];
    NSLog(@"lyz - new push url:%@", newPushURL);
    return newPushURL;
}


- (NSString *)MD5ForLower32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

#pragma mark - Gravity Motion
- (void)initMotionManager
{
    self.motionManager = [[CMMotionManager alloc] init];
//    if (self.motionManager.accelerometerAvailable) {
//        self.motionManager.accelerometerUpdateInterval = 0.1f;
//        __weak typeof(self) weakSelf = self;
//        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
//                                                 withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
//                                                     __strong typeof(self) strongSelf = weakSelf;
//                                                     if (strongSelf.motionManager) {
//                                                         CMAccelerometerData* newestAccel = strongSelf.motionManager.accelerometerData;
//                                                         double accelerationX = newestAccel.acceleration.x;
//                                                         double accelerationY = newestAccel.acceleration.y;
//                                                         double ra = atan2(-accelerationY, accelerationX);
//                                                         double degree = ra * 180 / M_PI;
//                                                         if (degree >= -105 && degree <= -75) {
//                                                             //NSLog(@"@keria motion: %f, 倒立", degree);
//                                                             mScreenRotation = 180;
//                                                         } else if (degree >= -15 && degree <= 15) {
//                                                             //NSLog(@"@keria motion: %f, 右转", degree);
//                                                             mScreenRotation = 90;
//                                                         } else if (degree >= 75 && degree <= 105) {
//                                                             //NSLog(@"@keria motion: %f, 正立", degree);
//                                                             mScreenRotation = 0;
//                                                         } else if (degree >= 165 || degree <= -165) {
//                                                             //NSLog(@"@keria motion: %f, 左转", degree);
//                                                             mScreenRotation = 270;
//                                                         }
//                                                     }
//                                                 }];
//    }
}

- (void)destroyMotionManager
{
    if (self.motionManager) {
        [self.motionManager stopAccelerometerUpdates];
        self.motionManager = nil;
    }
}

@end
