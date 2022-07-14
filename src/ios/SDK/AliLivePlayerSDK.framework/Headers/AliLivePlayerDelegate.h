//
//  AliLivePlayerDelegate.h
//  AliLivePlayerSDK
//
//  Copyright © 2021 Alibaba Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AliLivePlayer, AliLivePlayerInfo, AliLivePlayerFrameInfo, AliLivePlayerErrorInfo;

/* AliLivePlayer 的代理 */
@protocol AliLivePlayerDelegate <NSObject>

@optional

/**
 @brief 播放器开始渲染
 @param player 播放器player指针
 */
- (void)onRenderingStart:(AliLivePlayer *)player;

/**
 @brief 播放器渲染信息回调
 @param player 播放器player指针
 @param timeMs 渲染时的系统时间
 @param pts  视频帧pts
 */
- (void)onRenderFrame:(AliLivePlayer *)player timeMs:(int64_t)timeMs pts:(int64_t)pts;

/**
 @brief 播放器渲染信息回调
 @param player 播放器player指针
 @param info  视频帧的信息
 */
- (void)onRenderFrame:(AliLivePlayer *)player withInfo:(AliLivePlayerFrameInfo *)info;

/**
 @brief 视频大小变化回调
 @param player 播放器player指针
 @param width 视频宽度
 @param height 视频高度
 @param rotation 视频旋转角度
 */
- (void)onVideoSizeChanged:(AliLivePlayer *)player width:(int)width height:(int)height rotation:(float)rotation;

/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 */
- (void)onSnapShot:(AliLivePlayer *)player image:(UIImage *)image;

/**
 @brief SEI回调
 @param player 播放器player指针
 @param type 类型
 @param data 数据
 */
- (void)onSeiData:(AliLivePlayer *)player type:(int)type data:(NSData *)data;

/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorInfo 播放器错误描述，参考AVPErrorModel
 */
- (void)onErrorWithPlayer:(AliLivePlayer *)player andErrorInfo:(AliLivePlayerErrorInfo *)errorInfo;

@end
