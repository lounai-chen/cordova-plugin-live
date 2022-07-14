//
//  AliLivePlayerInfo.h
//  AliLivePlayerSDK
//
//  Copyright © 2021 Alibaba Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunPlayer/AliyunPlayer.h>

@interface AliLivePlayerInfo : NSObject

@property (nonatomic, assign) NSInteger event;

@property (nonatomic, copy) NSString *eventDescription;

- (instancetype)initWithEvent:(NSInteger)event andDescription:(NSString *)description;

@end

@interface AliLivePlayerErrorInfo : AVPErrorModel

@end
