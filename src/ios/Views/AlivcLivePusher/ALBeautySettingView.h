//
//  ALBeautySettingView.h
//  AliLiveSdk-Demo
//
//  Created by 薛林 on 2020/12/21.
//  Copyright © 2020 alilive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <queen/Queen.h>
#import <queen/QueenEngine.h>
#import <queen/QueenEngineConfigInfo.h>
#import "ALLiveItemSettingView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALBeautySettingViewDelegate <NSObject>

- (void) didChangeSliderValue:(NSDictionary *)message label:(NSString *)label;

// 隐藏slider
- (void)hiddenSlider:(BOOL)hidden;

@end
// 磨皮、美白滑动条
@interface ALSliderView : UIView
@property (nonatomic, strong) NSMutableDictionary *param;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *resetButton;
@end

@interface ALBeautySettingView : UIView
@property (nonatomic, weak) id<ALBeautySettingViewDelegate> delegate;
@property (nonatomic, copy) dispatch_block_t tapHidenHander;
@property (nonatomic, strong) QueenEngine *queenEngine;
@property (nonatomic, assign) int cameraRotate;
- (void)targetValueChanged:(CGFloat) value;
@end

NS_ASSUME_NONNULL_END
