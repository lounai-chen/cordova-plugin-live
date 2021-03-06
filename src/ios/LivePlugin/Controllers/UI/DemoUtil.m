//
//  DemoUtil.m
//  AliLiveSdk-Demo
//
//  Created by ZhouGuixin on 2020/8/4.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "DemoUtil.h"
#import <AVFoundation/AVCaptureDevice.h>

static NSThread *g_queenRenderThread = nil;

NSThread *getGlobalRenderThread()
{
    if (!g_queenRenderThread)
    {
        g_queenRenderThread = [[NSThread alloc] initWithBlock:^{
            NSPort *renderThreadKeepAlivePort = [NSPort port];
            NSRunLoop *rl = [NSRunLoop currentRunLoop];
            [rl addPort:renderThreadKeepAlivePort forMode: NSRunLoopCommonModes];
            [rl run];
        }];
        g_queenRenderThread.name = @"com.alivc.globalRenderThread";
        [g_queenRenderThread start];
    }
    return g_queenRenderThread;
}

void dispatch_thread_sync(NSThread* thread, dispatch_block_t block)
{
    if ([NSThread currentThread] == thread)
    {
        block();
    }
    else
    {
        [(id)block performSelector:@selector(invoke) onThread:thread withObject:nil waitUntilDone:YES];
    }
}

@implementation DemoUtil

+ (UIViewController *)createSelectUrlSheet:(NSArray *)urlConfig callback:(void (^)(NSString *name, NSString *url))callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [urlConfig enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = arr[0];
        NSString *url = arr[1];
        UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callback) {
                callback(name, url);
            }
        }];
        [alertController addAction:action];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    return alertController;
}

+ (void)setupApperance {
    UIButton *btnApperance1 = [UIButton appearance];
    [DemoUtil setupButtonApperance:btnApperance1];
}

+ (void)setupButtonApperance:(UIButton *)btnApperance {
    btnApperance.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnApperance setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnApperance setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    UIImage *normalBg = [DemoUtil roundRectBorderImageWithColor:[UIColor whiteColor]];
    UIImage *hilightBg = [DemoUtil roundRectBorderImageWithColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [btnApperance setBackgroundImage:normalBg forState:UIControlStateNormal];
    [btnApperance setBackgroundImage:hilightBg forState:UIControlStateHighlighted];
    btnApperance.layer.cornerRadius = 5.0f;
    [btnApperance.layer setMasksToBounds:YES];
}

+ (void)showToast:(NSString *)status {
    
    [DemoUtil showToastMessage:status];
}

+(void)showToastMessage:(NSString *)string{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:string duration:1.5 position:CSToastPositionCenter];
    });
}

+ (void)showErrorToast:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [DemoUtil showToastMessage:status];
        
    });
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmBlock:(void (^)(void))confirmBlock cancelBlock:(void (^)(void))cancelBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (confirmBlock) {
                confirmBlock();
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController != nil) {
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
                
            }];
        }
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
        }];
    });
}

+ (void)showTextInputAlert:(NSString *)title confirmBlock:(void (^)(NSString *string))confirmBlock {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:
UIAlertControllerStyleAlert];
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *string = [[alertVc textFields] objectAtIndex:0].text;
        if (confirmBlock) {
            confirmBlock(string);
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController != nil) {
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
        }];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:^{
    }];
}

static NSMutableDictionary *colorImageCache = nil;

+ (UIImage *)roundRectBorderImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    // 外层的圆
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5] addClip];
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    // 内层的圆
    CGRect rect1 = CGRectMake(1.0f, 1.0f, 18.0f, 18.0f);
    [[UIBezierPath bezierPathWithRoundedRect:rect1 cornerRadius:4] addClip];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect1);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *image1 = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    return image1;
}

+ (UIImage *)roundRectImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5] addClip];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *image1 = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    return image1;
}

+ (BOOL)getEssentialRights {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        }];
        return NO;
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [DemoUtil showAlertWithTitle:NSLocalizedString(@"提示",nil) message:NSLocalizedString(@"需要相机权限以开启直播功能",nil) confirmBlock:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } cancelBlock:^{
            
        }];
        return NO;
    }
    
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        }];
        return NO;
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [DemoUtil showAlertWithTitle:NSLocalizedString(@"提示",nil) message:NSLocalizedString(@"需要麦克风权限以开启直播功能",nil) confirmBlock:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } cancelBlock:^{
            
        }];
        return NO;
    }
    
    return YES;
}

+ (void)forceTestNetwork {
    NSURL *url = [NSURL URLWithString:@"https://www.taobao.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);
        }
    }];
    [dataTask resume];
}

//将日志写入沙盒mylog.log文件中
+(void)writeLogMessageToLocationFile:(NSString *)logMessagesString isCover:(BOOL)isCover{
        
    // NSDocumentDirectory 要查找的文件
    // NSUserDomainMask 代表从用户文件夹下找
    // 在iOS中，只有一个目录跟传入的参数匹配，所以这个集合里面只有一个元素
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *loggingPath = [documentsPath stringByAppendingPathComponent:@"/playerlog.log"];
    //NSLog(@"%@",loggingPath);
    
    //覆盖文件的原先内容
    if(isCover == YES) {
        [logMessagesString writeToFile:loggingPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    else {
        NSFileManager *fileManger = [NSFileManager defaultManager];
        if (![fileManger fileExistsAtPath:loggingPath]) {
            [logMessagesString writeToFile:loggingPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:loggingPath];
        [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
        
        NSData* stringData  = [logMessagesString dataUsingEncoding:NSUTF8StringEncoding];
        
        [fileHandle writeData:stringData]; //追加写入数据
        
        [fileHandle closeFile];
        
    }

}


@end
