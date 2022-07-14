//
//  AliLivePlayer.h
//  AliLivePlayerSDK
//
//  Copyright © 2021 Alibaba Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliLivePlayerDelegate.h"
#import <UIKit/UIKit.h>

@class AliLivePlayerConfiguration;

/* AliLivePlayer 的旋转模式 */
typedef NS_ENUM(NSInteger, AliLivePlayerRotateMode) {
    AliLivePlayerRotateModeZero,        // 无旋转
    AliLivePlayerRotateMode90,          // 旋转90度
    AliLivePlayerRotateMode180,         // 旋转180度
    AliLivePlayerRotateMode270          // 旋转270度
};

/* AliLivePlayer 的镜像模式 */
typedef NS_ENUM(NSInteger, AliLivePlayerMirrorMode) {
    AliLivePlayerMirrorModeNone,            // 无镜像
    AliLivePlayerMirrorModeHorizontal,      // 水平景象
    AliLivePlayerMirrorModeVertical         // 垂直镜像
};

/* AliLivePlayer 的填充模式 */
typedef NS_ENUM(NSInteger, AliLivePlayerScaleMode) {
    AliLivePlayerScaleAspectFit,        // 比例填充
    AliLivePlayerScaleAspectFill,       // 比例全屏
    AliLivePlayerScaleToFill            // 拉伸全屏
};

@interface AliLivePlayer : NSObject

/**
 @brief AliLivePlayer的代理
 */
@property (nonatomic, weak) id<AliLivePlayerDelegate> delegate;

/**
 @brief 初始化播放器
 */
- (instancetype)init;

/**
 @brief 初始化播放器，并对播放器进行设置
 @param configuration  AliLivePlayer 的配置
 */
- (instancetype)initWithConfiguration:(AliLivePlayerConfiguration *)configuration;

/**
 @brief 设置播放器的容器
 @param view  AliLivePlayer 的容器
 */
- (void)setSetRenderView:(UIView *)view;

/**
 @brief 开始播放URL
 @param url  AliLivePlayer 的链接
 */
- (void)startWithURL:(NSString *)url;

/**
 @brief 暂停播放
 */
- (void)pause;

/**
 @brief 继续播放
 */
- (void)resume;

/**
 @brief 停止播放
 */
- (void)stop;

/**
 @brief 设置 AliLivePlayer 的旋转模式
 */
- (void)setRotateMode:(AliLivePlayerRotateMode)rotateMode;

/**
 @brief 设置 AliLivePlayer 的镜像模式
 */
- (void)setMirrorMode:(AliLivePlayerMirrorMode)mirrorMode;

/**
 @brief 设置 AliLivePlayer 的填充模式
 */
- (void)setScaleMode:(AliLivePlayerScaleMode)scaleMode;

/**
 @brief 设置 AliLivePlayer 的音量
 */
- (void)setVolume:(float)value;

/**
 @brief 获取 AliLivePlayer 的音量
 */
- (float)getCurrentVolume;

/**
 @brief 设置静音开启关闭
 */
- (void)setMute:(BOOL)mute;

/**
 @brief 获取静音状态
 */
- (BOOL)isMute;

/**
 @brief 截屏
 */
- (void)snapshot;

/**
 @brief 设置播放器的初始化配置
 */
- (void)setConfiguration:(AliLivePlayerConfiguration *)configuration;

/**
 @brief 获取播放器的配置
 */
- (AliLivePlayerConfiguration *)getCurrentConfiguration;

@end
