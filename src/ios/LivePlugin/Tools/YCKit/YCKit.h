//
//  YCKit.h
//  YCKitTest
//
//  Created by yaochen.ww on 16/5/27.
//  Modify 16/7/25
//  Copyright (c) 2015年 com.taobao.mobileim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YCFunction.h"

@interface YCKit : NSObject

+ (instancetype)sharedInstance;

/**
 Enable YCKit. It will show a floating View.
 */
- (void)enable;
/*
 Set MainWindow level, default is (UIWindowLevelStatusBar - 1)
*/
- (void)setWindowLevel:(UIWindowLevel)windowLevel;

/**
 Disable YCKit. The window will be destroyed.
 */
- (void)disable;

/**
 If you have special Functions
 */
- (void)setCustomFunctions:(NSArray <__kindof YCFunction *> *)functions;

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

@end
