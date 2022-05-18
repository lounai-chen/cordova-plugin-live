//
//  AlivcCommonUtils.h
//  AlivcLivePusherDemo
//
//  Created by zhangjc on 2021/12/14.
//  Copyright © 2021 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcCommonUtils : NSObject

+ (void)nv12toRGBWithYUV:(unsigned char* )pYUV withRGB:(unsigned char*) rgb withWidht:(int)width withHeight:(int)height;

@end

NS_ASSUME_NONNULL_END
