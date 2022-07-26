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

// URL
@property (nonatomic, strong) NSString *pushURL;
@property (nonatomic, strong) NSString *playUrl;

// Push
@property (nonatomic, strong) NSString *pushUnder;
@property (nonatomic, assign) NSInteger *pushWidth;
@property (nonatomic, assign) NSInteger *pushHeight;
@property (nonatomic, assign) NSInteger *pushLeft;
@property (nonatomic, assign) NSInteger *pushTop;


// Player
@property (nonatomic, assign) NSInteger *playerWidth;
@property (nonatomic, assign) NSInteger *playerHeight;
@property (nonatomic, assign) NSInteger *playerLeft;
@property (nonatomic, assign) NSInteger *playerTop;


// SDK
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;

@property (nonatomic, assign) BOOL beautyOn;

@property (nonatomic, assign) BOOL isUseAsyncInterface;
@property (nonatomic, copy) NSString *authDuration;
@property (nonatomic, copy) NSString *authKey;

@property (nonatomic, assign) BOOL isUserMainStream;

@property (nonatomic, strong) AliLivePlayer *livePlayer;


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
