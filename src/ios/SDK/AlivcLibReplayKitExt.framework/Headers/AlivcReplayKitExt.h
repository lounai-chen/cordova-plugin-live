//
//  AlivcReplayKitExt.h
//  AlivcLibReplayKitExt
//
//  Created by siheng on 2021/9/29.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 屏幕分享主入口类，当前接口仅支持主 App 与 Extension 属于同一个App   Group的情况，如果不存在App Group， 不可调用该接口
 */
API_AVAILABLE(ios(10.0), tvos(10.0), macos(11.0))
@interface AlivcReplayKitExt : NSObject
/**
 获取单例对象接口
 */
+ (instancetype)sharedInstance;

/**
 * 设置 AppGroupId
 * 需要在 RPBroadcastSampleHandler 的实现类中的 broadcastStartedWithSetupInfo 方法中调用
 *
 @param appGroup App group ID
 */
- (void)setAppGroup:(NSString *)appGroup;

/**
 * 发送音视频数据
 * 需要在 RPBroadcastSampleHandler 的实现类中的 processSampleBuffer: 方法中调用
 *
 @param sampleBuffer 系统回调的视频或音频帧
 @param sampleBufferType 媒体输入类型
 */
- (void)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType;

/**
 * 完成录屏
 * 通过系统控制中心停止录屏时，会回调 RPBroadcastSampleHandler.broadcastFinished，在 broadcastFinished 方法中调用
 *
 */
- (void)finishBroadcast;
@end

NS_ASSUME_NONNULL_END
