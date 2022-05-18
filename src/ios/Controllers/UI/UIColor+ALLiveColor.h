//
//  UIColor+ALLiveColor.h
//  AliLiveSdk-Demo
//
//  Created by 薛林 on 2020/12/16.
//  Copyright © 2020 alilive. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ALLiveColor)
+ (UIColor *)colorWithHex:(long)hexColor;

+ (UIColor *)colorWithHexString:(NSString *)color;
 
//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
