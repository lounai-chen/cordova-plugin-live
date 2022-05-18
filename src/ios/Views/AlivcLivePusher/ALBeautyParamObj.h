//
//  ALBeautyParamObj.h
//  AliLiveSdk-Demo
//
//  Created by lichentao on 2021/2/27.
//  Copyright © 2021 alilive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALBeautyParamObj : NSObject

+ (NSArray *)initBeautyParams;

+ (void)configParamsWithType:(int)type Params:(NSDictionary *)params;

+ (NSDictionary *)getCoinfigParamsWithType:(int)type;

@end

NS_ASSUME_NONNULL_END
