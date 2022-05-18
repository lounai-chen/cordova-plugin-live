//
//  UIViewController+Rotate.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/3/16.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Rotate)

// 是否允许ViewController选择支持旋转方向
@property (nonatomic, assign) BOOL allowSelectInterfaceOrientation;

@end

NS_ASSUME_NONNULL_END
