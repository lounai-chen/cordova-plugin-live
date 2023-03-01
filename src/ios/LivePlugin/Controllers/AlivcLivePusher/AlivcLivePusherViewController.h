//
//  AlivcPublisherViewController.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDV.h>
#import <AliLivePlayerSDK/AliLivePlayerSDK.h>

@class AlivcLivePushConfig;

@interface AlivcLivePusherViewController : CDVViewController// UIViewController

@property (nonatomic, strong)NSString *hasePush;

// URL
@property (nonatomic, strong) NSString *pushURL;
@property (nonatomic, strong) NSString *playUrl;

// Push
@property (nonatomic, strong) NSString *pushUnder;
@property (nonatomic, assign) NSString *pushWidth;
@property (nonatomic, assign) NSString *pushHeight;
@property (nonatomic, assign) NSString *pushLeft;
@property (nonatomic, assign) NSString *pushTop;


// Player
@property (nonatomic, assign) NSString *playerWidth;
@property (nonatomic, assign) NSString *playerHeight;
@property (nonatomic, assign) NSString *playerLeft;
@property (nonatomic, assign) NSString *playerTop;


// SDK
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;

@property (nonatomic, assign) BOOL beautyOn;

@property (nonatomic, assign) BOOL isUseAsyncInterface;
@property (nonatomic, copy) NSString *authDuration;
@property (nonatomic, copy) NSString *authKey;

@property (nonatomic, assign) BOOL isUserMainStream;

@property (nonatomic, strong) AliPlayer *livePlayer;


- (int) start;
- (int) stop;

- (int)startPreviewPlugin;
- (int)StopPreviewPlugin;
- (int)pausePushPlugin;
- (int)resumePushPlugin;
- (int)restartPushPlugin;


- (void)CameraDirection;
- (void)LiveFlash;

- (void)setupPlayer;

- (void)PlayerStart;
- (void)PlayerPause;
- (void)PlayerResume;
- (void)PlayerStop;
- (void)PlayerSnapshot;
- (void)PlayerIsMute;
- (void)PlayerSetVolume: (float )playVolume;
- (void)PlayerMirrorMode;
- (void)PlayerScaleMode;
- (void)PlayerRotateMode;
@end
