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

- (void)PlayerStart;


@end
