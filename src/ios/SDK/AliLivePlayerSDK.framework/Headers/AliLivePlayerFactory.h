//
//  AliLivePlayerFactory.h
//  AliLivePlayerSDK
//
//  Copyright © 2021 Alibaba Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AliLivePlayer;

@interface AliLivePlayerFactory : NSObject

/**
 @brief 创建一个 AliLivePlayer
 */
+ (AliLivePlayer *)createAliLivePlayer;

/**
 @brief 销毁一个 AliLivePlayer
 */
+ (void)releaseAliLivePlayer:(AliLivePlayer *)player;

@end

