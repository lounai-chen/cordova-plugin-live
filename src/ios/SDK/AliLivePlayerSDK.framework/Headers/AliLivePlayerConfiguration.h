//
//  AliLivePlayerConfiguration.h
//  AliLivePlayerSDK
//
//  Copyright © 2021 Alibaba Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliLivePlayerConfiguration : NSObject

/**
 @brief SEI数据回调开关，默认 NO
*/
@property (nonatomic, assign) BOOL enableSEI;

/**
 @brief 音视频帧回调开关，默认NO
*/
@property (nonatomic, assign) BOOL enableFrameInfo;

/**
 @brief 最大延迟。注意：直播有效。单位ms。当延时比较大时，播放器sdk内部会追帧等，保证播放器的延时在这个范围内。
 */
@property (nonatomic, assign) int maxDelayTime;

/**
 @brief 最大缓冲区时长。单位ms。播放器每次最多加载这么长时间的缓冲数据。
 */
@property (nonatomic, assign) int maxBufferDuration;

/**
 @brief 高缓冲时长。单位ms。当网络不好导致加载数据时，如果加载的缓冲时长到达这个值，结束加载状态。
 */
@property (nonatomic, assign) int highBufferDuration;

/**
 @brief 起播缓冲区时长。单位ms。这个时间设置越短，起播越快。也可能会导致播放之后很快就会进入加载状态。
 */
@property (nonatomic, assign) int startBufferDuration;

/**
 @brief 最大probe大小。单位 byte 。 -1：默认。
*/
@property (nonatomic, assign) int maxProbeSize;

@end

NS_ASSUME_NONNULL_END
