//
//  DemoUtil.h
//  AliLiveSdk-Demo
//
//  Created by ZhouGuixin on 2020/8/4.
//  Copyright © 2020 alilive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NSThread *getGlobalRenderThread();
void dispatch_thread_sync(NSThread* thread, dispatch_block_t block);

@interface DemoUtil : NSObject

+ (UIViewController *)createSelectUrlSheet:(NSArray *)urlConfig callback:(void (^)(NSString *name, NSString *url))callback;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmBlock:(void (^)(void))confirmBlock cancelBlock:(void (^)(void))cancelBlock;
+ (void)showTextInputAlert:(NSString *)title confirmBlock:(void (^)(NSString *string))confirmBlock;

+ (void)setupApperance;
+ (void)showToast:(NSString *)status;
+(void)showToastMessage:(NSString *)string;
+ (void)showErrorToast:(NSString *)status;
+ (UIImage *)roundRectImageWithColor:(UIColor *)color;

+ (BOOL)getEssentialRights;

+ (NSString *)mkCurrentDeviceInfo;

// 强制发一个网络请求，弹出网络授权框
+ (void)forceTestNetwork;

// 保存日志
+(void)writeLogMessageToLocationFile:(NSString *)logMessagesString isCover:(BOOL)isCover;

@end

NS_ASSUME_NONNULL_END
